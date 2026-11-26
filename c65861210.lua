--三幻魔の失楽園
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合最多3次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）3张相同种类（怪兽·魔法·陷阱）的卡送去墓地。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「三幻魔」怪兽特殊召唤。这个效果特殊召唤的怪兽不受对方发动的魔法·陷阱卡的效果影响。
-- ②：自己场上有原本等级是10星的「三幻魔」怪兽存在的场合才能发动。自己抽2张。
local s,id,o=GetID()
-- 初始化卡片效果：注册场地魔法卡的发动效果，并注册①效果（1回合最多3次，将3张同种类手卡·场上表侧卡送墓并可选特召「三幻魔」怪兽且赋予魔陷抗性）与②效果（场上有原本10星「三幻魔」怪兽时抽2张）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合最多3次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）3张相同种类（怪兽·魔法·陷阱）的卡送去墓地。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「三幻魔」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(3)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。 ②：自己场上有原本等级是10星的「三幻魔」怪兽存在的场合才能发动。自己抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 筛选条件：检查卡片是否为表侧表示（含手卡）且可送去墓地
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave()
end
-- 子组校验函数：检查所选3张卡是否全部属于同一种类（全为怪兽、全为魔法或全为陷阱）
function s.gcheck(g,tp)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)==3
		or g:FilterCount(Card.IsType,nil,TYPE_SPELL)==3
		or g:FilterCount(Card.IsType,nil,TYPE_TRAP)==3
end
-- ①效果的发动检测与连锁信息设置：确认手卡·场上存在3张同种类可送墓的卡，提示对方并登记送去墓地操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方手卡与场上除自身外所有表侧且可送去墓地的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3,tp) end
	-- 向对方提示己方选择发动了①效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记连锁的送去墓地操作信息，预计将己方手卡·场上3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
-- 筛选条件：检查卡片是否为表侧表示（含手卡·卡组·墓地·除外区）的「三幻魔」怪兽，且能按其对应的召唤方式特殊召唤
function s.spfilter(c,e,tp)
	if not c:IsFaceupEx() or not c:IsSetCard(0x1144) then return false end
	-- 检查该「三幻魔」怪兽是否可以被特殊召唤（并根据辅助函数判断是否忽略其特殊召唤限制）
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c))
end
-- ①效果的处理流程：选3张同种类其他卡送去墓地且均进入墓地后，若有空位且手卡·卡组·墓地·除外区有「三幻魔」怪兽则可选特殊召唤1只并赋予其不受对方发动的魔陷效果影响
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方手卡与场上除自身外所有表侧且可送去墓地的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	if not g:CheckSubGroup(s.gcheck,3,3,tp) then return end
	-- 向己方提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 将所选的3张同种类卡以效果送去墓地，并确认3张均成功送去墓地
	if sg and Duel.SendtoGrave(sg,REASON_EFFECT)==3
		and sg:IsExists(Card.IsLocation,3,nil,LOCATION_GRAVE)
		-- 检查己方主要怪兽区是否存在可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方手卡·卡组·墓地·除外区是否存在符合条件且不受王家长眠之谷阻碍的「三幻魔」怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问己方是否特殊召唤「三幻魔」怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从手卡·卡组·墓地·除外区选择1只满足条件的「三幻魔」怪兽
		local spg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=spg:GetFirst()
		-- 中断效果处理，使后续的特殊召唤与前面的送去墓地视为不同时处理
		Duel.BreakEffect()
		if tc then
			local res=false
			-- 获取该「三幻魔」怪兽是否需无视召唤限制与苏生限制的标记
			local flag=aux.PhantasmsSpSummonType(tc)
			-- 执行分步特殊召唤，将所选「三幻魔」怪兽以表侧表示特殊召唤到己方场上
			res=Duel.SpecialSummonStep(tc,0,tp,tp,false,flag,POS_FACEUP)
			if res then
				-- 这个效果特殊召唤的怪兽不受对方发动的魔法·陷阱卡的效果影响。
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,3))  --"「三幻魔的失乐园」的效果特殊召唤"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetRange(LOCATION_MZONE)
				e1:SetCode(EFFECT_IMMUNE_EFFECT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.efilter)
				e1:SetOwnerPlayer(tp)
				tc:RegisterEffect(e1,true)
				if flag then
					tc:CompleteProcedure()
				end
			end
			-- 完成分步特殊召唤并统一触发召唤相关时点
			Duel.SpecialSummonComplete()
		end
	end
end
-- 效果免疫过滤函数：判定仅免疫由对方玩家发动的魔法·陷阱卡的效果
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 筛选条件：检查场上怪兽是否为表侧表示、原本等级为10的「三幻魔」怪兽
function s.drcfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()==10 and c:IsSetCard(0x1144)
end
-- ②效果的发动条件检查：确认己方场上存在原本等级为10星的「三幻魔」怪兽
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区是否存在表侧表示且原本等级为10的「三幻魔」怪兽
	return Duel.IsExistingMatchingCard(s.drcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动检测与连锁信息设置：确认己方可以抽2张卡，提示对方并登记抽卡目标与操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方玩家可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 向对方提示己方选择发动了②抽卡效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁的目标玩家设为己方
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数（抽卡数量）设为2
	Duel.SetTargetParam(2)
	-- 登记连锁的抽卡操作信息，预计使己方抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果的处理流程：读取连锁目标玩家与数量并执行抽2张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果使目标玩家抽2张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
