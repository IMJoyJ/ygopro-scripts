--フォーチュンレディ・リワインド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以除外的自己的「命运女郎」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
function c84218527.initial_effect(c)
	-- ①：以除外的自己的「命运女郎」怪兽任意数量为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,84218527+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c84218527.sptg)
	e1:SetOperation(c84218527.spop)
	c:RegisterEffect(e1)
end
-- 过滤除外区中正面表示且可以特殊召唤的「命运女郎」怪兽
function c84218527.filter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备，包括对象选择、合法性检测和特殊召唤的操作信息注册
function c84218527.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c84218527.filter(chkc,e,tp) end
	-- 获取玩家场上可用的主要怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动阶段的第0步，检查场上是否有空位，以及除外区是否存在至少1只符合条件的「命运女郎」怪兽
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c84218527.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取除外区中所有符合条件且可以作为效果对象的「命运女郎」怪兽
	local g=Duel.GetMatchingGroup(c84218527.filter,tp,LOCATION_REMOVED,0,nil,e,tp):Filter(Card.IsCanBeEffectTarget,nil,e)
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择任意数量（不超过可用怪兽区域数）且卡名互不相同的怪兽作为对象
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选择的怪兽群注册为当前连锁的效果对象
	Duel.SetTargetCard(tg)
	-- 设置当前连锁的操作信息，表明此效果包含特殊召唤，并指定特殊召唤的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- 效果①的效果处理，将作为对象的怪兽特殊召唤，并注册结束阶段回到持有者卡组的效果
function c84218527.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 在效果处理时，重新获取玩家场上可用的主要怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中仍与该效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<1 or g:GetCount()<1 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		local tc=g:GetFirst()
		while tc do
			-- 将目标怪兽以表侧表示特殊召唤到场上（分步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(84218527,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=g:GetNext()
		end
		-- 完成所有分步特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c84218527.retcon)
		e1:SetOperation(c84218527.retop)
		-- 将结束阶段回到卡组的延迟效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	else
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		local tc=sg:GetFirst()
		while tc do
			-- 将目标怪兽以表侧表示特殊召唤到场上（分步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(84218527,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=sg:GetNext()
		end
		-- 完成所有分步特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c84218527.retcon)
		e1:SetOperation(c84218527.retop)
		-- 将结束阶段回到卡组的延迟效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		g:Sub(sg)
		-- 根据规则，将因格子不足而无法特殊召唤的其余对象怪兽送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
-- 过滤出带有当前效果唯一标识（fid）的怪兽
function c84218527.retfilter(c,fid)
	return c:GetFlagEffectLabel(84218527)==fid
end
-- 检查是否存在带有当前效果唯一标识的怪兽，若不存在则重置该延迟效果
function c84218527.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c84218527.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 在结束阶段，将所有带有当前效果唯一标识的怪兽送回持有者的卡组
function c84218527.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c84218527.retfilter,nil,e:GetLabel())
	-- 将目标怪兽群送回持有者的卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
