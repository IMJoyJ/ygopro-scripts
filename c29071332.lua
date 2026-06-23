--アームズ・エイド
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽的攻击力上升1000。此外，装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力数值的伤害。
function c29071332.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29071332,0))  --"当作装备卡使用给怪兽装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c29071332.eqtg)
	e1:SetOperation(c29071332.eqop)
	c:RegisterEffect(e1)
end
-- 设置效果目标为场上1只表侧表示怪兽
function c29071332.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 判断是否满足发动条件：该回合未发动过此效果且玩家场上存在装备区域
	if chk==0 then return e:GetHandler():GetFlagEffect(29071332)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足发动条件：场上存在1只表侧表示怪兽作为目标
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置连锁操作信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(29071332,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备卡效果处理函数，执行装备操作并注册后续效果
function c29071332.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 装备解除时可以特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29071332,1))  --"装备解除特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c29071332.sptg)
	e1:SetOperation(c29071332.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力数值的伤害
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29071332,2))  --"给予对方伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c29071332.damcon)
	e3:SetTarget(c29071332.damtg)
	e3:SetOperation(c29071332.damop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- 限制只能装备给特定怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c29071332.eqlimit)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetLabelObject(tc)
	c:RegisterEffect(e4)
end
-- 装备限制效果的判断函数，仅允许装备给指定目标怪兽
function c29071332.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤效果的目标判定函数
function c29071332.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：该回合未发动过此效果且玩家场上存在召唤区域
	if chk==0 then return e:GetHandler():GetFlagEffect(29071332)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置连锁操作信息，表示将要进行特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(29071332,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果处理函数，将装备卡特殊召唤到场上
function c29071332.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将装备卡以特殊召唤方式送入场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 伤害触发条件判断函数，判断是否为装备怪兽战斗破坏的怪兽
function c29071332.damcon(e,tp,eg,ep,ev,re,r,rp)
	local eqc=e:GetHandler():GetEquipTarget()
	local des=eg:GetFirst()
	return des:IsLocation(LOCATION_GRAVE) and des:GetReasonCard()==eqc and des:IsType(TYPE_MONSTER)
end
-- 伤害效果的目标设定函数，设置伤害对象为对方玩家
function c29071332.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	eg:GetFirst():CreateEffectRelation(e)
	-- 设置连锁操作信息的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息，表示将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 伤害效果处理函数，计算并给予对方伤害
function c29071332.damop(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if des:IsRelateToEffect(e) then
		local dam=des:GetAttack()
		if dam<0 then dam=0 end
		-- 给与对方指定数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
