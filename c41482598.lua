--悪夢の蜃気楼
-- 效果：
-- 对方的准备阶段时，自己抽卡直到4张手卡。自己的准备阶段时，随机丢弃那个效果所抽的卡的数量的手卡。
function c41482598.initial_effect(c)
	-- 效果原文：对方的准备阶段时，自己抽卡直到4张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41482598.clear)
	c:RegisterEffect(e1)
	-- 效果原文：自己的准备阶段时，随机丢弃那个效果所抽的卡的数量的手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41482598,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c41482598.drcon)
	e2:SetTarget(c41482598.drtg)
	e2:SetOperation(c41482598.drop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 效果作用：设置魔陷发动时的处理流程
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41482598,1))  --"丢弃"
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c41482598.dccon)
	e3:SetTarget(c41482598.dctg)
	e3:SetOperation(c41482598.dcop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
-- 效果作用：初始化效果标签为0
function c41482598.clear(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
end
-- 效果作用：判断是否为对方准备阶段且手牌少于4张
function c41482598.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否为对方准备阶段且手牌少于4张
	return Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<4
end
-- 效果作用：设置抽卡操作信息
function c41482598.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：获取当前手牌数量
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 效果作用：设置抽卡操作信息，目标为抽到4张手卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,4-ht)
end
-- 效果作用：执行抽卡操作并记录抽卡数量
function c41482598.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前手牌数量
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ht<4 then
		-- 效果作用：执行抽卡操作
		Duel.Draw(tp,4-ht,REASON_EFFECT)
		e:GetLabelObject():SetLabel(4-ht)
	else e:GetLabelObject():SetLabel(0) end
end
-- 效果作用：判断是否为己方准备阶段且之前抽卡数量不为0
function c41482598.dccon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否为己方准备阶段且之前抽卡数量不为0
	return Duel.GetTurnPlayer()==tp and e:GetLabelObject():GetLabel()~=0
end
-- 效果作用：设置丢弃操作信息
function c41482598.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local de=e:GetLabelObject()
	e:SetLabel(de:GetLabel())
	de:SetLabel(0)
	-- 效果作用：设置丢弃操作信息，目标为丢弃指定数量的手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,e:GetLabel())
end
-- 效果作用：执行随机丢弃手牌操作
function c41482598.dcop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(tp,e:GetLabel())
	-- 效果作用：将随机选择的手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
end
