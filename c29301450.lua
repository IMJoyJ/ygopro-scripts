--S：Pリトルナイト
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用融合·同调·超量·连接怪兽的其中任意种为素材作连接召唤的场合，以自己或对方的场上·墓地1张卡为对象才能发动。那张卡除外。这个回合，自己怪兽不能直接攻击。
-- ②：对方的效果发动时，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那2只怪兽直到结束阶段除外。
local s,id,o=GetID()
-- 定义卡片初始化函数：启用苏生限制，指定连接召唤素材条件（2只效果怪兽），并注册①效果（含素材检查）、②效果；其中①效果在连接召唤时用融合/同调/超量/连接素材为素材时触发，除外场上/墓地1张卡，且本回合己方怪兽不能直接攻击；②效果在对方发动效果时，除外双方场上2只表侧怪兽直到结束阶段。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2只效果怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2)
	-- ①：这张卡用融合·同调·超量·连接怪兽的其中任意种为素材作连接召唤的场合，以自己或对方的场上·墓地1张卡为对象才能发动。那张卡除外。这个回合，自己怪兽不能直接攻击。
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
	-- 这张卡用融合·同调·超量·连接怪兽的其中任意种为素材作连接召唤的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetLabelObject(e1)
	e2:SetValue(s.mchk)
	c:RegisterEffect(e2)
	-- ②：对方的效果发动时，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那2只怪兽直到结束阶段除外。
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
-- ①效果发动条件：这张卡是连接召唤成功，且素材检查标记为1（素材中含有融合·同调·超量·连接怪兽中的任意一种）。
function s.srmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- ①效果的目标选择阶段：从自己或对方的场上·墓地中选1张可以除外的卡作为对象；优先选择场上的卡，场上不足时从墓地选择，并设置除外操作信息。
function s.srmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	-- 发动合法性检查：确认自己或对方的场上·墓地存在至少1张可以除外的卡，满足后才能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 显示‘请选择要除外的卡’的选择提示，供玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张自己或对方场上·墓地的可除外卡作为效果对象（优先选场上，若场上合法对象不足则从墓地选），并自动设为连锁对象。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	-- 设置本次效果处理的预定信息：将上述选择的1张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：将对象卡以表侧表示除外；然后给己方怪兽附加‘不能直接攻击’的永续效果，直到回合结束。
function s.srmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果选择的连锁对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与该效果关联，则将其表侧除外。
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
	-- ①中的素材条件‘这张卡用融合·同调·超量·连接怪兽的其中任意种为素材作连接召唤的场合’；①中的不能直击‘这个回合，自己怪兽不能直接攻击’；②的完整效果‘对方的效果发动时，以包含自己场上的怪兽的场上2只表侧表示怪兽为对象才能发动。那2只怪兽直到结束阶段除外’。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘己方怪兽不能直接攻击’的永续效果以场上效果形式注册，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 素材检查：若这张卡作为连接召唤的素材中含有融合·同调·超量·连接怪兽中的任意一种，则将①效果的标签设为1，否则设为0。
function s.mchk(e,c)
	if c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
		e:GetLabelObject():SetLabel(1)
	else e:GetLabelObject():SetLabel(0) end
end
-- ②效果发动条件：只有对方玩家发动效果（rp==1-tp）时才能发动。
function s.drmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 第1只目标怪兽的过滤条件：表侧表示且可以除外，并且存在于自己场上；同时还要求场上存在另一只可除外的表侧表示怪兽（确保有第2只可选）。
function s.cfilter1(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		-- 追加判定：在场上还存在另一只满足cfilter2（表侧且可除外）的怪兽，以便作为第2只目标。
		and Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 第2只目标怪兽的过滤条件：表侧表示且可以除外，不限制控制者（可为双方场上任意表侧怪兽）。
function s.cfilter2(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- ②效果的目标选择：先在自己场上选1只表侧且可除外的怪兽，再在双方场上选另1只表侧且可除外的怪兽作为对象，合计2只；并设置除外2张卡的操作信息。
function s.drmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己场上存在至少1只表侧且可除外、并能凑齐2只目标的怪兽（即满足cfilter1的卡）。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示‘请选择要除外的卡’的选择提示，供玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧且可除外的怪兽作为第1只目标，并自动设置为连锁对象。
	local g=Duel.SelectTarget(tp,s.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 显示‘请选择要除外的卡’的选择提示，供玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方场上另1只表侧且可除外的怪兽作为第2只目标（不能与第1只重复），并自动设置为连锁对象。
	local g2=Duel.SelectTarget(tp,s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g)
	g:Merge(g2)
	-- 设置本次效果处理的预定信息：将上述2只目标怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- ②效果处理：取得仍关联的2只对象怪兽，若对象数不为2，或暂时除外失败，或没有任何卡进入除外区，则直接结束处理。
function s.drmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得仍与当前连锁相关的对象怪兽组，并过滤出其中可以除外的卡。
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsAbleToRemove,nil)
	-- 如果对象卡数量不是2张，或对这些卡进行暂时除外（REASON_EFFECT+REASON_TEMPORARY）失败，或没有任何卡进入除外区，则直接终止效果处理。
	if #g~=2 or Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)==0
			or not g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then return end
	-- 取得刚才因效果实际被暂时除外的卡组中位于除外区的卡，作为之后要返回场上的对象组。
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 遍历这些暂时除外的卡，为每张卡设置一个本次效果处理使用的标记（fid），以便在结束阶段识别并返回。
	for tc in aux.Next(og) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	og:KeepAlive()
	-- ②：那2只怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(fid)
	e1:SetLabelObject(og)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 将结束阶段执行返回的连续效果注册到当前玩家场上，当到达结束阶段时触发返回处理。
	Duel.RegisterEffect(e1,tp)
end
-- 返回过滤函数：判断某张卡是否带有本次暂时除外时设定的标志ID（fid），从而确认它属于要返回的怪兽。
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段返回效果的发动条件：若被暂时除外的怪兽组中还存在带本次fid标记的卡，则执行返回；若已不存在（例如卡片已离开除外区），则清除对象组并重置该效果，不执行返回。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil,e:GetLabel()) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end
-- 结束阶段返回处理：将带本次fid标记的被除外怪兽按原控制者分别返回场上；若同一控制者需要返回的怪兽数量多于可用怪兽区空格，则需选择其中1只返回（其余无法返回），最后清除对象组。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	if #g<=0 then return end
	-- 向双方展示该卡（S：P小夜骑士）的卡片动画，提示正在执行其返回效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 按当前回合玩家和对方的顺序遍历双方玩家，分别返回属于各自控制的怪兽。
	for p in aux.TurnPlayers() do
		local tg=g:Filter(Card.IsPreviousControler,nil,p)
		-- 获取玩家p当前可用的怪兽区空格数，用于判断是否有格子返回怪兽。
		local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
		if #tg>1 and ft==1 then
			-- 当可返回怪兽数多于可用格子时，给玩家p发送‘请选择要放置到场上的卡’的提示。
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sg=tg:Select(p,1,1,nil)
			-- 将玩家选择的那张怪兽（sg中的第一张）返回场上。
			Duel.ReturnToField(sg:GetFirst())
			tg:Sub(sg)
		end
		-- 遍历剩余需要返回的怪兽。
		for tc in aux.Next(tg) do
			-- 将怪兽tc返回场上（按离场前的表示形式）；若没有可用区域则无法返回。
			Duel.ReturnToField(tc)
		end
	end
	e:GetLabelObject():DeleteGroup()
end
