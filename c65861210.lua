--三幻魔の失楽園
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合最多3次，自己主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）3张相同种类（怪兽·魔法·陷阱）的卡送去墓地。那之后，可以把自己的手卡·卡组·墓地·除外状态的1只「三幻魔」怪兽特殊召唤。这个效果特殊召唤的怪兽不受对方发动的魔法·陷阱卡的效果影响。
-- ②：自己场上有原本等级是10星的「三幻魔」怪兽存在的场合才能发动。自己抽2张。
local s,id,o=GetID()
-- 注册卡片效果的 initial_effect 函数
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
	-- ②：自己场上有原本等级是10星的「三幻魔」怪兽存在的场合才能发动。自己抽2张。
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
-- 过滤送去墓地的卡片条件（表侧表示且可以送去墓地）
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsAbleToGrave()
end
-- 检查选择的卡片组是否为3张相同种类的怪兽、魔法或陷阱卡
function s.gcheck(g,tp)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)==3
		or g:FilterCount(Card.IsType,nil,TYPE_SPELL)==3
		or g:FilterCount(Card.IsType,nil,TYPE_TRAP)==3
end
-- 效果①的特殊召唤及送去墓地效果的发动准备与检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取除这张卡以外的自己手卡·场上表侧表示的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(s.gcheck,3,3,tp) end
	-- 向对方玩家提示已选择发动本效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置将3张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
-- 过滤可被特殊召唤的「三幻魔」怪兽的条件
function s.spfilter(c,e,tp)
	if not c:IsFaceupEx() or not c:IsSetCard(0x1144) then return false end
	-- 检查怪兽是否可以以正规或特定方式进行特殊召唤
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c))
end
-- 效果①的特殊召唤及送去墓地效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取除了这张卡以外，自己手卡·场上可以送去墓地的表侧表示的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	if not g:CheckSubGroup(s.gcheck,3,3,tp) then return end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 玩家选择3张卡并成功送去墓地
	if sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT)==3
		and sg:IsExists(Card.IsLocation,3,nil,LOCATION_GRAVE)
		-- 检查自己场上的怪兽区域是否有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地、除外状态是否存在可以特殊召唤的「三幻魔」怪兽（受王家之谷的影响过滤）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问玩家是否决定特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择要特殊召唤的「三幻魔」怪兽
		local spg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=spg:GetFirst()
		-- 中断效果处理，使之后的效果处理与送去墓地不视为同时处理
		Duel.BreakEffect()
		if tc then
			local res=false
			-- 获取该「三幻魔」怪兽的特殊召唤类型标记
			local flag=aux.PhantasmsSpSummonType(tc)
			-- 将选择的「三幻魔」怪兽在自己场上表侧表示特殊召唤
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
			-- 结束特殊召唤的步骤处理
			Duel.SpecialSummonComplete()
		end
	end
end
-- 效果过滤函数：确定不受对方发动的魔法、陷阱卡的效果影响
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤场上原本等级为10星的「三幻魔」怪兽的条件
function s.drcfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()==10 and c:IsSetCard(0x1144)
end
-- 效果②的发动条件检测函数
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在原本等级是10星的「三幻魔」怪兽
	return Duel.IsExistingMatchingCard(s.drcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的抽卡效果的发动准备与检测函数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，检查玩家是否可以效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 向对方玩家提示已选择发动本效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将抽卡的目标玩家设定为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将抽卡的参数值设定为2
	Duel.SetTargetParam(2)
	-- 设置抽2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果②的抽卡效果的处理函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡处理，玩家抽2张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
