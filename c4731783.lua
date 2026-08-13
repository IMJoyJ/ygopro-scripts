--光なき影 ア＝バオ・ア・クゥー
-- 效果：
-- 包含恶魔族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，可以丢弃1张手卡，从以下效果选择1个发动。
-- ●场上1张卡破坏。
-- ●这张卡直到结束阶段除外，从自己墓地把1只光·暗属性怪兽特殊召唤。
-- ②：自己准备阶段才能发动。自己抽出自己墓地的怪兽的种族种类的数量。那之后，选抽出数量的自己手卡用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 初始化效果：为这张卡设定连接召唤手续（包含恶魔族怪兽的怪兽2只以上），并注册①的诱发即时效果和②的诱发效果，同时设置各自1回合1次的发动限制。
function s.initial_effect(c)
	-- 添加连接召唤手续：以2～99只怪兽为素材，且素材组需通过s.lcheck检查（至少包含1只恶魔族怪兽）。
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段，可以丢弃1张手卡，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.accon)
	e1:SetCost(s.accost)
	e1:SetTarget(s.actarget)
	e1:SetOperation(s.acoperation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己准备阶段才能发动。自己抽出自己墓地的怪兽的种族种类的数量。那之后，选抽出数量的自己手卡用喜欢的顺序回到卡组下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.dract)
	c:RegisterEffect(e2)
end
-- 连接素材检查：素材组中必须存在至少1只恶魔族怪兽，以满足“包含恶魔族怪兽的怪兽2只以上”的召唤条件。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- ①效果的发动条件：必须在自己或对方的主要阶段才能发动。
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，作为①效果的发动条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①效果的代价函数：丢弃1张手卡作为发动代价。
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动代价是否可行：手牌中是否存在1张可丢弃的卡（且不是要发动效果的那张卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手牌选择1张卡丢弃去墓地，原因为cost并视为手卡丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤对象的过滤条件：从自己墓地选择光属性或暗属性、且可以被玩家tp以效果e特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理：判断两个选项是否可行，让玩家选择其中一个，并据此设置效果分类及操作信息。
function s.actarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 选项1的可行性判断：双方场上是否存在至少1张卡，可作为破坏对象。
	local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 选项2的可行性判断之一：这张卡自身能够被除外，且除外后自己场上仍有空余的怪兽区。
	local b2=c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0
		-- 选项2的可行性判断之二：自己墓地存在符合条件的可特殊召唤的光·暗属性怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家从两个可选分支（破坏卡片/除外自身并特殊召唤）中选择一个，并将选择结果保存到效果的Label中。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2)},  --"破坏"
		{b2,aux.Stringid(id,3)})  --"除外并特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 若选择破坏，获取场上所有卡作为可能被破坏的对象集合，用于后续操作信息判定。
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置操作信息：本次效果可能破坏1张卡，对象范围为双方场上所有卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		-- 若选择除外并特殊召唤，设置操作信息：本次效果会将这张卡自身除外。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
		-- 设置操作信息：本次效果会从自己墓地特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
-- ①效果的处理函数：根据之前选择的分支执行“场上1张卡破坏”或“这张卡直到结束阶段除外，从墓地特殊召唤光·暗属性怪兽”。
function s.acoperation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 显示选择提示，让玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从双方场上选择1张卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 为选中的卡播放被指定为对象的动画，并记录其被选为对象。
			Duel.HintSelection(g)
			-- 将选择的卡以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		local c=e:GetHandler()
		-- 当选择“除外并特殊召唤”时，先判断这张卡仍与效果有联系且被暂时除外成功，然后才执行后续特殊召唤。
		if c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			if c:GetOriginalCode()==id then
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				-- ●这张卡直到结束阶段除外，从自己墓地把1只光·暗属性怪兽特殊召唤。②：自己准备阶段才能发动。自己抽出自己墓地的怪兽的种族种类的数量。那之后，选抽出数量的自己手卡用喜欢的顺序回到卡组下面。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(c)
				e1:SetCountLimit(1)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				-- 将结束阶段返回场上的效果e1注册到场上，使其在结束阶段时触发。
				Duel.RegisterEffect(e1,tp)
			end
			-- 检查自己场上是否有空余的怪兽区，用于后续特殊召唤。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 且自己墓地存在符合条件的可特殊召唤怪兽（已通过王家长眠之谷的过滤检查）。
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) then
				-- 显示选择提示，让玩家选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从自己墓地选择1只光/暗属性且符合条件的怪兽作为特殊召唤对象。
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				-- 将选择到的怪兽以表侧攻击表示特殊召唤到自己场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 返回效果的发动条件：被暂时除外的这张卡仍带有标记id，说明其尚未失去返回资格。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 返回效果的处理：将暂时除外的这张卡返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将e:GetLabelObject()（被暂时除外的这张卡）实际返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- ②效果的发动条件：自己的准备阶段，并且当前回合玩家是自己。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保仅在自己准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的目标处理：统计自己墓地怪兽的种族种类数，并设定抽卡及回卡组的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地的全部怪兽，用于统计种族种类数。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local ct=g:GetClassCount(Card.GetRace)
	-- 发动合法性检查：种族种类数大于0，且自己可以抽对应数量的卡。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置连锁的对象玩家为自己，以便处理时知道由谁执行抽卡和回卡组。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的对象参数为抽卡数量（即种族种类数）。
	Duel.SetTargetParam(ct)
	-- 设置操作信息：本次效果会抽取ct张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	-- 设置操作信息：本次效果会将ct张手卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_HAND)
end
-- ②效果的处理函数：抽取墓地怪兽种族种类数量的卡，然后选择等量手卡按喜欢的顺序放回卡组底。
function s.dract(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取自己墓地的怪兽并计算种族种类数（与发动时确定的数量一致）。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local ct=g:GetClassCount(Card.GetRace)
	-- 从连锁信息中取得目标玩家（即自己），用于抽卡及后续回卡组操作。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行抽卡：让目标玩家抽取ct张卡，抽卡原因为效果。
	local dc=Duel.Draw(p,ct,REASON_EFFECT)
	if dc>0 then
		-- 中断当前效果，使抽卡与后续回卡组的处理不在同一时点，避免错过时点。
		Duel.BreakEffect()
		-- 显示选择提示，让玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择与抽卡数量相同数量的卡（必须恰好dc张）。
		local rg=Duel.GetFieldGroup(p,LOCATION_HAND,0):Select(p,dc,dc,nil)
		-- 洗切手卡，确保按玩家选择的顺序放回卡组底时顺序正确。
		Duel.ShuffleHand(p)
		-- 将选中的手卡按玩家喜欢的顺序放到卡组底端，原因为效果。
		aux.PlaceCardsOnDeckBottom(p,rg)
	end
end
