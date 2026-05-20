--ヴァイロン・テセラクト
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「大日」的怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，可以从自己墓地选择1只4星以下的名字带有「大日」的怪兽特殊召唤。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c84313685.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「大日」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84313685,0))  --"变成装备卡"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c84313685.eqtg)
	e1:SetOperation(c84313685.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84313685,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的发动条件为这张卡处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c84313685.sptg)
	e2:SetOperation(c84313685.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的发动条件为这张卡处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	-- 设置代替破坏的过滤条件（因战斗或效果被破坏）
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，可以从自己墓地选择1只4星以下的名字带有「大日」的怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84313685,2))  --"墓地特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c84313685.gspcon)
	e4:SetTarget(c84313685.gsptg)
	e4:SetOperation(c84313685.gspop)
	c:RegisterEffect(e4)
	-- 1只怪兽可以装备的同盟最多1张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c84313685.eqlimit)
	c:RegisterEffect(e5)
end
c84313685.old_union=true
-- 限制同盟装备对象为「大日」怪兽
function c84313685.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 过滤场上表侧表示、未装备同盟怪兽的「大日」怪兽
function c84313685.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30) and c:GetUnionCount()==0
end
-- 装备效果的目标过滤与选择
function c84313685.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c84313685.filter(chkc) end
	-- 检查本回合是否未使用过同盟效果，且魔法与陷阱区域有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(84313685)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以装备的合法「大日」怪兽
		and Duel.IsExistingTarget(c84313685.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「大日」怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c84313685.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息为装备选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(84313685,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c84313685.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为装备对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c84313685.filter(tc) then
		-- 若目标怪兽已不合法，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置这张卡处于同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤解除装备效果的目标过滤与选择
function c84313685.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未使用过同盟效果，且主要怪兽区域有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(84313685)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(84313685,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤解除装备效果的执行函数
function c84313685.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 装备怪兽战斗破坏对方怪兽时特殊召唤效果的发动条件函数
function c84313685.gspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否处于同盟装备状态，且战斗破坏对方怪兽的是其装备的怪兽
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 过滤墓地中4星以下、可以特殊召唤的「大日」怪兽
function c84313685.gfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x30) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地特殊召唤效果的目标过滤与选择
function c84313685.gsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84313685.gfilter(chkc,e,tp) end
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的4星以下「大日」怪兽
		and Duel.IsExistingTarget(c84313685.gfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「大日」怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c84313685.gfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 墓地特殊召唤效果的执行函数
function c84313685.gspop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为特殊召唤对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
