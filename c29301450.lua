--S：Pリトルナイト
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用融合·同调·超量·连接怪兽的其中任意种为素材作连接召唤的场合，以自己或对方的场上·墓地1张卡为对象才能发动。那张卡除外。这个回合，自己怪兽不能直接攻击。
-- ②：对方的效果发动时，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那2只怪兽直到结束阶段除外。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2张效果怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- 效果①：连接召唤成功时发动，除外对方场上或墓地的1张卡，且本回合自己怪兽不能直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.srmcon)
	e1:SetTarget(s.srmtg)
	e1:SetOperation(s.srmop)
	c:RegisterEffect(e1)
	-- 效果①的触发条件检查，判断是否为连接召唤且满足条件
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetLabelObject(e1)
	e2:SetValue(s.mchk)
	c:RegisterEffect(e2)
	-- 效果②：对方发动效果时发动，除外自己场上的2只表侧表示怪兽直到结束阶段
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.drmcon)
	e3:SetTarget(s.drmtg)
	e3:SetOperation(s.drmop)
	c:RegisterEffect(e3)
end
-- 效果①的触发条件，判断是否为连接召唤且满足条件
function s.srmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 效果①的目标选择处理，选择场上或墓地的1张可除外卡
function s.srmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	-- 效果①的目标选择检查，判断是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择目标卡
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的处理，将目标卡除外并设置本回合不能直接攻击
function s.srmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标卡
	local tc=Duel.GetFirstTarget()
	-- 如果目标卡有效则将其除外
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
	-- 设置本回合不能直接攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能直接攻击的效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查连接召唤所用的素材是否包含融合/同调/超量/连接怪兽
function s.mchk(e,c)
	if c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
		e:GetLabelObject():SetLabel(1)
	else e:GetLabelObject():SetLabel(0) end
end
-- 效果②的触发条件，判断是否为对方发动效果
function s.drmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②的目标选择条件1，选择自己场上的1只表侧表示怪兽
function s.cfilter1(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		-- 检查是否存在满足条件的第二只目标怪兽
		and Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 效果②的目标选择条件2，选择自己场上的1只表侧表示怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果②的目标选择处理，选择2只表侧表示怪兽
function s.drmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果②的目标选择检查，判断是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择第一只目标怪兽
	local g=Duel.SelectTarget(tp,s.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择第二只目标怪兽
	local g2=Duel.SelectTarget(tp,s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g)
	g:Merge(g2)
	-- 设置操作信息，记录将要除外的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 效果②的处理，将目标怪兽除外并设置返回场上的效果
function s.drmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁相关的所有目标怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsAbleToRemove,nil)
	-- 判断是否成功除外2只怪兽
	if #g~=2 or Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)==0
			or not g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then return end
	-- 获取实际被除外的怪兽组
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 遍历被除外的怪兽
	for tc in aux.Next(og) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	og:KeepAlive()
	-- 注册结束阶段返回场上的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(fid)
	e1:SetLabelObject(og)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 注册返回场上的效果
	Duel.RegisterEffect(e1,tp)
end
-- 返回怪兽的标记ID是否匹配
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 返回场上的效果触发条件，判断是否还有需要返回的怪兽
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil,e:GetLabel()) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end
-- 返回场上的效果处理，将怪兽返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	if #g<=0 then return end
	-- 提示卡片发动动画
	Duel.Hint(HINT_CARD,0,id)
	-- 遍历当前回合玩家
	for p in aux.TurnPlayers() do
		local tg=g:Filter(Card.IsPreviousControler,nil,p)
		-- 获取玩家场上空位数
		local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
		if #tg>1 and ft==1 then
			-- 提示玩家选择要返回场上的卡
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=tg:Select(p,1,1,nil)
			-- 将选中的卡返回场上
			Duel.ReturnToField(sg:GetFirst())
			tg:Sub(sg)
		end
		-- 遍历需要返回场上的怪兽
		for tc in aux.Next(tg) do
			-- 将怪兽返回场上
			Duel.ReturnToField(tc)
		end
	end
	e:GetLabelObject():DeleteGroup()
end
