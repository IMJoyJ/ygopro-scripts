--E・HERO ゴッド・ネオス
-- 效果：
-- 这张卡不用融合召唤不能特殊召唤。名字带有「新宇」·「新空间侠」·「英雄」的怪兽各有1只以上，合计5只的怪兽为融合素材作融合召唤。1回合1次，可以通过把自己墓地存在的1只名字带有「新宇」·「新空间侠」·「英雄」的怪兽从游戏中除外，这张卡的攻击力上升500。并且，直到结束阶段时得到和那只怪兽相同的效果。
function c31111109.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用「新宇」「新空间侠」「英雄」任一字段的怪兽2只作为通用素材，再分别用这3个字段的怪兽各1只，合计5只作为融合素材进行融合召唤。
	aux.AddFusionProcMixRep(c,true,true,c31111109.ffilter,2,2,c31111109.ffilter1,c31111109.ffilter2,c31111109.ffilter3)
	-- 1回合1次，可以通过把自己墓地存在的1只名字带有「新宇」·「新空间侠」·「英雄」的怪兽从游戏中除外，这张卡的攻击力上升500。并且，直到结束阶段时得到和那只怪兽相同的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31111109,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c31111109.copycost)
	e2:SetOperation(c31111109.copyop)
	c:RegisterEffect(e2)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为aux.fuslimit，即只允许通过融合召唤方式特殊召唤，禁止其他特殊召唤。
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
c31111109.material_setcode=0x8
-- 通用融合素材筛选：融合素材可以是带有「新宇」「新空间侠」「英雄」其中任一字段的怪兽。
function c31111109.ffilter(c,fc)
	return c:IsFusionSetCard(0x9,0x1f,0x8)
end
-- 筛选带有「新宇」字段的融合素材。
function c31111109.ffilter1(c,fc)
	return c:IsFusionSetCard(0x9)
end
-- 筛选带有「新空间侠」字段的融合素材。
function c31111109.ffilter2(c,fc)
	return c:IsFusionSetCard(0x1f)
end
-- 筛选带有「英雄」字段的融合素材。
function c31111109.ffilter3(c,fc)
	return c:IsFusionSetCard(0x8)
end
-- 代价筛选：从自己墓地选择1只带有「新宇」「新空间侠」「英雄」之一的怪兽，且该怪兽可作为代价从墓地除外。
function c31111109.filter(c)
	return c:IsSetCard(0x9,0x1f,0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价函数：检查并选择墓地符合条件的怪兽，将其表侧除外作为发动代价，并把其卡号记录到连锁参数，供效果处理时复制其效果。
function c31111109.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1张满足筛选条件的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31111109.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给出提示文本，让玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 弹出选择窗口，从自己墓地选择1张满足条件的怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c31111109.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧表示除外，作为发动代价。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	local code=tc:GetOriginalCode()
	-- 将所选怪兽的原始卡号保存到连锁参数中，供后续效果处理时识别要复制的效果。
	Duel.SetTargetParam(code)
end
-- 效果处理函数：从连锁参数取得代价怪兽的卡号，若卡号有效且本卡仍在场上表侧表示，则复制该怪兽的效果并使这张卡攻击力上升500；同时注册一个结束阶段的重置效果，在结束阶段时解除复制效果和攻击力变化。
function c31111109.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中取出代价阶段写入的目标参数（即被除外怪兽的卡号）。
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if code~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 并且，直到结束阶段时得到和那只怪兽相同的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(31111109,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabel(cid)
		e2:SetLabelObject(e1)
		e2:SetOperation(c31111109.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段的重置操作：将攻击力变化效果重置，并清除通过CopyEffect复制的效果，使这张卡恢复到原本状态。
function c31111109.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	local atke=e:GetLabelObject()
	if atke then
		atke:SetReset(RESET_EVENT+RESETS_STANDARD)
	end
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT+RESETS_STANDARD)
	if atke then
		atke:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	end
	-- 手动展示这张卡的选中动画，提示玩家该卡的效果正在重置/结束。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家发送提示消息，显示本效果描述，告知对方本卡的效果适用结束。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
