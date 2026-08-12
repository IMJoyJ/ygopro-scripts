--ロード・シンクロン
-- 效果：
-- ①：把这张卡作为「王道战士」以外的同调怪兽的素材的场合，当作这张卡的等级下降2星的等级使用。
-- ②：这张卡攻击的场合，那次伤害步骤结束时发动。这张卡的等级直到回合结束时上升1星。
function c71971554.initial_effect(c)
	-- ②：这张卡攻击的场合，那次伤害步骤结束时发动。这张卡的等级直到回合结束时上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71971554,0))  --"等级上升1"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c71971554.lvcon)
	e1:SetOperation(c71971554.lvop)
	c:RegisterEffect(e1)
	-- ①：把这张卡作为「王道战士」以外的同调怪兽的素材的场合，当作这张卡的等级下降2星的等级使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(c71971554.lvval)
	c:RegisterEffect(e2)
end
-- 定义效果②的触发条件函数，判断此卡是否进行攻击且在伤害步骤结束时仍存在于场上
function c71971554.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽是否为本卡，且本卡在伤害步骤结束时仍与战斗相关联
	return Duel.GetAttacker()==e:GetHandler() and e:GetHandler():IsRelateToBattle()
end
-- 定义效果②的操作函数，若此卡表侧表示存在且与效果相关联，则使其等级直到回合结束时上升1星
function c71971554.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的等级直到回合结束时上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
-- 计算同调素材等级的函数：若用于同调召唤「王道战士」则使用当前等级，否则等级下降2星（若等级小于等于2则返回特定值以防等级变为0或负数）
function c71971554.lvval(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsCode(2322421) then return lv
	else
		if lv<=2 then return 16 end
		return lv-2
	end
end
