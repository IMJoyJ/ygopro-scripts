--E・HERO ゴッド・ネオス
-- 效果：
-- 这张卡不用融合召唤不能特殊召唤。名字带有「新宇」·「新空间侠」·「英雄」的怪兽各有1只以上，合计5只的怪兽为融合素材作融合召唤。1回合1次，可以通过把自己墓地存在的1只名字带有「新宇」·「新空间侠」·「英雄」的怪兽从游戏中除外，这张卡的攻击力上升500。并且，直到结束阶段时得到和那只怪兽相同的效果。
function c31111109.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求使用满足ffilter、ffilter1、ffilter2、ffilter3条件的怪兽各1只，合计2只作为融合素材进行融合召唤
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
	-- 这张卡不用融合召唤不能特殊召唤。名字带有「新宇」·「新空间侠」·「英雄」的怪兽各有1只以上，合计5只的怪兽为融合素材作融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤方式必须为融合召唤
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
c31111109.material_setcode=0x8
-- 融合素材过滤函数，判断怪兽是否同时具有新宇、新空间侠、英雄属性
function c31111109.ffilter(c,fc)
	return c:IsFusionSetCard(0x9,0x1f,0x8)
end
-- 融合素材过滤函数，判断怪兽是否具有新宇属性
function c31111109.ffilter1(c,fc)
	return c:IsFusionSetCard(0x9)
end
-- 融合素材过滤函数，判断怪兽是否具有新空间侠属性
function c31111109.ffilter2(c,fc)
	return c:IsFusionSetCard(0x1f)
end
-- 融合素材过滤函数，判断怪兽是否具有英雄属性
function c31111109.ffilter3(c,fc)
	return c:IsFusionSetCard(0x8)
end
-- 墓地过滤函数，判断怪兽是否具有新宇、新空间侠、英雄属性且为怪兽卡
function c31111109.filter(c)
	return c:IsSetCard(0x9,0x1f,0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，检查玩家墓地是否存在满足条件的怪兽，若存在则选择1只除外作为代价
function c31111109.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31111109.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从玩家墓地选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c31111109.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽从游戏中除外作为代价
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	local code=tc:GetOriginalCode()
	-- 将被除外怪兽的卡号设置为连锁参数
	Duel.SetTargetParam(code)
end
-- 效果处理函数，获取被除外怪兽的卡号并复制其效果，同时增加攻击力500点
function c31111109.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标参数，即被除外怪兽的卡号
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if code~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 增加攻击力500点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 设置一个持续到结束阶段的效果，用于在结束阶段时移除复制的效果
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
-- 结束阶段处理函数，移除复制的效果并显示提示信息
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
	-- 为该卡显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方提示该卡发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
