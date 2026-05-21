--宵星の閃光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的怪兽数量比自己场上的怪兽多2只以上的场合才能发动。对方可以把自身场上的怪兽任意数量送去墓地。自己让对方场上的怪兽数量的以下效果适用。
-- ●0只：自己基本分变成一半。
-- ●1只：对方回复2000基本分。
-- ●2只：对方手卡全部直到结束阶段表侧除外。
-- ●3只以上：这个回合，对方不能把怪兽的效果发动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义魔法卡的发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方场上的怪兽数量比自己场上的怪兽多2只以上的场合才能发动。对方可以把自身场上的怪兽任意数量送去墓地。自己让对方场上的怪兽数量的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RECOVER+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 发动条件：判断对方场上的怪兽数量是否比自己场上的怪兽多2只以上。
function s.con(e,tp,eg,ep,ev,re,r,rp)
	-- 比较自己与对方场上的怪兽数量，若对方比自己多2只以上则返回true。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-2
end
-- 过滤函数：筛选对方场上可以送去墓地且不受当前效果免疫的怪兽。
function s.tgfilter(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 效果发动时的目标选择与预估操作信息注册。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有满足送去墓地条件的怪兽。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_MZONE,nil,e)
	-- 设置操作信息：预计将对方场上的怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理核心逻辑：对方选择是否将怪兽送去墓地，并根据剩余怪兽数量适用对应的效果。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上满足送去墓地条件的怪兽。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_MZONE,nil,e)
	-- 如果对方场上有可送去墓地的怪兽，询问对方是否将任意数量的怪兽送去墓地。
	if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否把怪兽送去墓地？"
		-- 对方选择自身场上任意数量不受效果免疫的怪兽。
		local tg=g:FilterSelect(1-tp,aux.NOT(Card.IsImmuneToEffect),1,g:GetCount(),nil,e)
		-- 将对方选择的怪兽送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
	-- 立即刷新场上卡片状态信息，确保后续怪兽数量统计准确。
	Duel.AdjustAll()
	-- 获取当前对方场上的怪兽数量。
	local ss=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ss==0 then
		-- 对方场上怪兽为0只时，将自己的基本分变成一半。
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
	elseif ss==1 then
		-- 对方场上怪兽为1只时，对方回复2000基本分。
		Duel.Recover(1-tp,2000,REASON_EFFECT)
	elseif ss==2 then
		-- 对方场上怪兽为2只时，获取对方的全部手卡。
		local rg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		-- 将对方手卡全部表侧表示暂时除外，并判断是否成功除外。
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			-- 获取本次操作中实际被除外的卡片组。
			local og=Duel.GetOperatedGroup()
			local fid=og:GetFirst():GetFieldID()
			-- 遍历实际被除外的卡片。
			for tc in aux.Next(og) do
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			end
			og:KeepAlive()
			-- ●2只：对方手卡全部直到结束阶段表侧除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(og)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册在结束阶段将除外的手卡送回手卡的时点效果。
			Duel.RegisterEffect(e1,tp)
		end
	elseif ss>=3 then
		-- ●2只：对方手卡全部直到结束阶段表侧除外。●3只以上：这个回合，对方不能把怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制对方发动怪兽效果的全局效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数：筛选带有对应标识且需要归还手卡的卡片。
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段手卡归还效果的发动条件：检查是否存在需要归还的卡片，若不存在则重置该效果。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段手卡归还效果的处理：将所有被该效果除外的卡片送回持有者手卡。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 遍历需要归还的卡片。
	for tc in aux.Next(sg) do
		-- 将卡片送回其原本控制者的手卡。
		Duel.SendtoHand(tc,tc:GetPreviousControler(),REASON_EFFECT)
	end
end
-- 限制函数：判断发动效果的卡片是否为怪兽，用于限制对方怪兽效果的发动。
function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
