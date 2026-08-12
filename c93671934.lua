--士気高揚
-- 效果：
-- 每当1张装备魔法卡装备在怪兽身上时，这张装备魔法的控制者回复1000基本分。每当1张装备魔法卡离场时，这张装备魔法的控制者受到1000点伤害。
function c93671934.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每当1张装备魔法卡装备在怪兽身上时，这张装备魔法的控制者回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c93671934.reccon)
	e2:SetTarget(c93671934.rectg)
	e2:SetOperation(c93671934.recop)
	c:RegisterEffect(e2)
	-- 每当1张装备魔法卡离场时，这张装备魔法的控制者受到1000点伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c93671934.damcon)
	e3:SetTarget(c93671934.damtg)
	e3:SetOperation(c93671934.damop)
	c:RegisterEffect(e3)
end
-- 回复效果的发动条件：获取当前装备的装备魔法卡的控制者并将其作为Label保存
function c93671934.reccon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(eg:GetFirst():GetControler())
	return true
end
-- 回复效果的发动目标：设置回复基本分的操作信息
function c93671934.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在效果处理时使该装备魔法卡的控制者回复1000基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,e:GetLabel(),1000)
end
-- 回复效果的效果处理：使该装备魔法卡的控制者回复1000基本分
function c93671934.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该装备魔法卡的控制者回复1000基本分
	Duel.Recover(e:GetLabel(),1000,REASON_EFFECT)
end
-- 过滤离场的卡片中属于装备魔法卡（有装备对象或因失去装备对象而离场）的卡
function c93671934.filter(c)
	return c:GetEquipTarget()~=nil or c:IsReason(REASON_LOST_TARGET)
end
-- 伤害效果的发动条件：筛选出离场的装备魔法卡，并根据其控制者（玩家0、玩家1或双方）设置Label标记
function c93671934.damcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c93671934.filter,nil)
	if g:GetCount()==0 then return false end
	local flag=0
	if g:IsExists(Card.IsControler,1,nil,0) then flag=flag+1 end
	if g:IsExists(Card.IsControler,1,nil,1) then flag=flag+2 end
	e:SetLabel(({0,1,PLAYER_ALL})[flag])
	return true
end
-- 伤害效果的发动目标：设置给与玩家伤害的操作信息
function c93671934.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在效果处理时给与该装备魔法卡的控制者1000点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetLabel(),1000)
end
-- 伤害效果的效果处理：根据Label标记，给与对应的装备魔法卡控制者1000点伤害，并完成伤害时点
function c93671934.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1-tp then
		-- 给与自己（或玩家0）1000点伤害（分步处理）
		Duel.Damage(tp,1000,REASON_EFFECT,true)
	end
	if e:GetLabel()~=tp then
		-- 给与对方（或玩家1）1000点伤害（分步处理）
		Duel.Damage(1-tp,1000,REASON_EFFECT,true)
	end
	-- 完成伤害/回复LP过程的分解，触发相关时点
	Duel.RDComplete()
end
