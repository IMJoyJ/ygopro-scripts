--三幻魔の失楽園
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合最多3次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）3张相同种类（怪兽·魔法·陷阱）的卡送去墓地。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「三幻魔」怪兽特殊召唤。这个效果特殊召唤的怪兽不受对方发动的魔法·陷阱卡的效果影响。
-- ②：自己场上有原本等级是10星的「三幻魔」怪兽存在的场合才能发动。自己抽2张。
local s,id,o=GetID()
-- 初始化卡片效果（注册卡片发动、送墓特招三幻魔以及抽卡效果）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合最多3次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）3张相同种类（怪兽·魔法·陷阱）的卡送去墓地。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「三幻魔」怪兽特殊召唤。这个效果特殊召唤的怪兽不受对方发动的魔法·陷阱卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(3)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有原本等级是10星的「三幻魔」怪兽存在的场合才能发动。自己抽2张。
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
-- 过滤手卡以及场上表侧表示可送去墓地的卡
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave()
end
-- 检查选取的卡片是否为3张相同种类（怪兽·魔法·陷阱）
function s.gcheck(g,tp)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)==3
		or g:FilterCount(Card.IsType,nil,TYPE_SPELL)==3
		or g:FilterCount(Card.IsType,nil,TYPE_TRAP)==3
end
-- 送墓特招效果的目标确认与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取除自身外手卡·场上表侧表示可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3,tp) end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置将手卡·场上3张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
-- 过滤可特殊召唤的「三幻魔」怪兽
function s.spfilter(c,e,tp)
	if not c:IsFaceupEx() or not c:IsSetCard(0x1144) then return false end
	-- 判断是否能特殊召唤（包含幻魔专用召唤手续判定）
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c))
end
-- 执行送去墓地并特殊召唤「三幻魔」怪兽的效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取除自身外手卡·场上表侧表示可送去墓地的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	if not g:CheckSubGroup(s.gcheck,3,3,tp) then return end
	-- 设置选择送去墓地卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 将选中的3张卡送去墓地，并确认成功送去3张
	if sg and Duel.SendtoGrave(sg,REASON_EFFECT)==3
		and sg:IsExists(Card.IsLocation,3,nil,LOCATION_GRAVE)
		-- 检查主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地·除外状态是否存在可以特殊召唤的「三幻魔」怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问玩家是否进行特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 设置选择特殊召唤怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地·除外状态选择1只「三幻魔」怪兽
		local spg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=spg:GetFirst()
		-- 中断效果处理，使之后的特殊召唤视为不同时处理
		Duel.BreakEffect()
		if tc then
			local res=false
			-- 获取三幻魔特殊召唤的手续标志
			local flag=aux.PhantasmsSpSummonType(tc)
			-- 将选中的「三幻魔」怪兽表侧表示特殊召唤
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
			-- 完成特殊召唤操作流程
			Duel.SpecialSummonComplete()
		end
	end
end
-- 过滤对方发动的魔法·陷阱卡效果（赋予不受影响抗性）
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤原本等级为10星且表侧表示的「三幻魔」怪兽
function s.drcfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()==10 and c:IsSetCard(0x1144)
end
-- 抽卡效果的发动条件判定
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在原本等级是10星的「三幻魔」怪兽
	return Duel.IsExistingMatchingCard(s.drcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 抽卡效果的目标确认与操作信息设置
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置抽卡效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标参数为2（抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置抽2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽卡效果操作
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家与抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 目标玩家以效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
