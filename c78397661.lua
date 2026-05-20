--黒き竜のエクレシア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
local s,id,o=GetID()
-- 注册卡片初始效果的入口函数
function s.initial_effect(c)
	-- 建立卡片关联密码列表，记录本卡记述了「阿不思的落胤」（密码为68468459）
	aux.AddCodeList(c,68468459)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段才能发动。这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的墓地·除外状态的1只8星融合怪兽和场上1张卡为对象才能发动。那2张卡和这张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数：自己或对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 效果①特殊召唤怪兽的过滤条件：卡名是「阿不思的落胤」或记述了该卡名、4星以下、且能特殊召唤
function s.spfilter(c,e,tp)
	-- 检查卡片是否为「阿不思的落胤」或记述了该卡名，且等级在4星以下，并满足特殊召唤条件
	return aux.IsCodeOrListed(c,68468459) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target阶段），检查自身是否能除外以及卡组·墓地是否有可特召的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查在自身离场后，自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		and c:IsAbleToRemove()
		-- 检查自己的卡组或墓地是否存在至少1只满足特召条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息：将自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置连锁处理信息：从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果①的执行函数：将自身暂时除外，并从卡组或墓地特殊召唤怪兽，同时注册回合结束时自身返回场上的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 若此卡仍存在于连锁中，则将其作为效果处理暂时除外
	if c:IsRelateToChain() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))  --"直到结束阶段除外"
			-- 这张卡直到结束阶段除外，从自己的卡组·墓地把1只「阿不思的落胤」或者有那个卡名记述的4星以下的怪兽特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册在回合结束时将此卡返回场上的延迟效果
			Duel.RegisterEffect(e1,tp)
		end
		-- 检查自己场上是否有空余的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己的卡组或墓地（受王家之谷影响）选择1只满足条件的怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 暂时除外的卡返回场上的条件判定：检查标记是否一致，若不一致则重置该效果
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 暂时除外的卡返回场上的执行函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的此卡返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 效果②中墓地·除外状态的8星融合怪兽的过滤条件：表侧表示（除外区）、等级8、融合怪兽，且场上存在可回到卡组的卡
function s.tdfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevel(8) and c:IsType(TYPE_FUSION)
		-- 并且场上存在至少1张可以回到卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果②的发动准备（Target阶段）：选择墓地·除外状态的1只8星融合怪兽和场上1张卡作为对象
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查自己墓地或除外状态是否存在满足条件的8星融合怪兽，且自身能回到卡组
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) and c:IsAbleToDeck() end
	-- 提示玩家选择要回到卡组的卡（第一张，8星融合怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地或除外状态的1只8星融合怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	-- 提示玩家选择要回到卡组的卡（第二张，场上的卡）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张可以回到卡组的卡作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	g1:AddCard(c)
	-- 设置连锁处理信息：将选中的2张卡以及墓地的自身（共3张卡）送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,3,0,0)
end
-- 过滤不能回到卡组的卡的辅助函数
function s.ntdfilter(c)
	return not c:IsAbleToDeck()
end
-- 效果②的执行函数：将作为对象的2张卡和墓地的此卡回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil,e)
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if not c:IsRelateToChain() then return end
	g:AddCard(c)
	local res=true
	-- 遍历对象中处于墓地的卡片
	for tc in aux.Next(sg) do
		-- 检查墓地的卡片是否受到「王家长眠之谷」的影响
		if not aux.NecroValleyFilter()(tc) then res=false end
	end
	if g:IsExists(s.ntdfilter,1,nil) then return end
	if res and g:GetCount()==3 then
		-- 将所有目标卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
