--ミス・ケープ・バーバ
-- 效果：
-- 怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的战斗阶段开始时，以这张卡或者这张卡所连接区1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
function c67073561.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤的手续，需要2只怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,2)
	-- ①：自己·对方的战斗阶段开始时，以这张卡或者这张卡所连接区1只怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67073561,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,67073561)
	e1:SetTarget(c67073561.rmtg)
	e1:SetOperation(c67073561.rmop)
	c:RegisterEffect(e1)
end
-- 过滤条件：属于自身或自身所连接区的怪兽，且可以被除外
function c67073561.rmfilter(c,g)
	return g:IsContains(c) and c:IsAbleToRemove()
end
-- 效果①的发动准备与对象选择
function c67073561.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	lg:AddCard(c)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c67073561.rmfilter(chkc,lg) end
	-- 检查场上是否存在可以作为效果对象的、属于自身或所连接区的可除外怪兽
	if chk==0 then return Duel.IsExistingTarget(c67073561.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只自身或所连接区的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67073561.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
	-- 设置效果处理信息，表示该效果的操作分类为除外，数量为1
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的效果处理：将对象怪兽暂时除外，并注册在结束阶段将其返回场上的延迟效果
function c67073561.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍对该效果有效，则将其因效果暂时除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(67073561,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 那只怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c67073561.retcon)
		e1:SetOperation(c67073561.retop)
		-- 注册该全局延迟效果，用于在回合结束时将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：被除外的怪兽身上仍带有该效果注册的标记
function c67073561.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(67073561)~=0
end
-- 延迟效果的处理：将暂时除外的怪兽返回到场上
function c67073561.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
