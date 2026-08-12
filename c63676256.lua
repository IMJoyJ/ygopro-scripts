--バスター・ショットマン
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽的攻击力·守备力下降500。装备怪兽战斗破坏对方怪兽的场合，场上表侧表示存在的和破坏的怪兽相同种族的怪兽全部破坏。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c63676256.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63676256,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c63676256.eqtg)
	e1:SetOperation(c63676256.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63676256,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 限制只有在作为同盟装备卡装备的状态下才能发动此效果
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c63676256.sptg)
	e2:SetOperation(c63676256.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 限制只有在作为同盟装备卡装备的状态下代破效果才适用
	e3:SetCondition(aux.IsUnionState)
	-- 设置代破的适用条件为战斗或效果破坏
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 1只怪兽可以装备的同盟最多1张。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNION_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽的攻击力·守备力下降500。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	-- 限制只有在作为同盟装备卡装备的状态下才降低攻击力
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(-500)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	-- 装备怪兽战斗破坏对方怪兽的场合，场上表侧表示存在的和破坏的怪兽相同种族的怪兽全部破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(63676256,2))  --"破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	e7:SetCondition(c63676256.descon)
	e7:SetTarget(c63676256.destg)
	e7:SetOperation(c63676256.desop)
	c:RegisterEffect(e7)
end
c63676256.old_union=true
-- 过滤出场上表侧表示且未装备同盟怪兽的怪兽
function c63676256.filter(c)
	return c:IsFaceup() and c:GetUnionCount()==0
end
-- 装备效果的发动条件与靶向判定
function c63676256.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63676256.filter(chkc) end
	-- 判定本回合是否尚未发动过同盟效果，且魔法与陷阱区域有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(63676256)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以装备同盟怪兽的合法怪兽
		and Duel.IsExistingTarget(c63676256.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c63676256.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息为装备选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(63676256,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c63676256.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c63676256.filter(tc) then
		-- 若装备目标已不合法，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 将自身状态设置为同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动条件与靶向判定
function c63676256.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定本回合是否尚未发动过同盟效果，且怪兽区域有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(63676256)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(63676256,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c63676256.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 判定装备怪兽战斗破坏对方怪兽的触发条件
function c63676256.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否处于同盟装备状态，且进行战斗破坏的怪兽是装备怪兽
	return aux.IsUnionState(e) and eg:GetCount()==1 and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 过滤出场上表侧表示且与被破坏怪兽种族相同的怪兽
function c63676256.dfilter(c,rac)
	return c:IsFaceup() and c:IsRace(rac)
end
-- 破坏效果的发动条件与靶向判定
function c63676256.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst():GetBattleTarget()
	-- 获取场上所有与被破坏怪兽种族相同的表侧表示怪兽
	local desg=Duel.GetMatchingGroup(c63676256.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetRace())
	-- 设置效果处理信息为破坏这些相同种族的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,desg,desg:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c63676256.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst():GetBattleTarget()
	-- 重新获取场上所有与被破坏怪兽种族相同的表侧表示怪兽
	local desg=Duel.GetMatchingGroup(c63676256.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetRace())
	-- 破坏所有符合条件的相同种族怪兽
	Duel.Destroy(desg,REASON_EFFECT)
end
