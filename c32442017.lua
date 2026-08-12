--終刻撃針
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1张其他的「终刻」卡破坏。那之后，从卡组选1只「终刻」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动和两个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己的手卡·场上（表侧表示）1张其他的「终刻」卡破坏。那之后，从卡组选1只「终刻」怪兽加入手卡或特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏并检索"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏怪兽"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断手卡或场上的「终刻」卡是否满足破坏条件并能检索或特殊召唤「终刻」怪兽
function s.cfilter(c,e,tp,chk)
	return c:IsSetCard(0x1d2) and c:IsFaceupEx()
		-- 判断是否能检索或特殊召唤「终刻」怪兽
		and (not chk or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c,chk))
end
-- 过滤函数，判断卡组中的「终刻」怪兽是否可以加入手卡或特殊召唤
function s.thfilter(c,e,tp,ec)
	return c:IsSetCard(0x1d2) and c:IsType(TYPE_MONSTER)
		-- 判断「终刻」怪兽是否可以加入手卡或特殊召唤
		and (c:IsAbleToHand() or (Duel.GetMZoneCount(tp,ec)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果的发动条件判断，检查是否有满足条件的「终刻」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「终刻」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp,true) end
	-- 获取满足条件的「终刻」卡组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler(),e,tp,true)
	-- 设置操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行破坏并检索或特殊召唤操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local dg=nil
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 检查是否有满足条件的「终刻」卡
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e,tp,true) then
		-- 选择要破坏的「终刻」卡
		dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),e,tp,true)
	else
		-- 选择要破坏的「终刻」卡
		dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,aux.ExceptThisCard(e),e,tp,false)
	end
	if dg and dg:GetCount()>0 then
		local fg=dg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		if fg:GetCount()>0 then
			-- 显示被选为对象的卡
			Duel.HintSelection(fg)
		end
		-- 破坏选中的卡
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then
			-- 提示玩家选择要操作的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
			-- 从卡组选择要加入手卡或特殊召唤的「终刻」怪兽
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
			-- 获取玩家场上可用的怪兽区数量
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local tc=g:GetFirst()
			if tc then
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 判断是否选择加入手卡或特殊召唤
				if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
					-- 将卡加入手卡
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
					-- 确认对方查看该卡
					Duel.ConfirmCards(1-tp,tc)
				else
					-- 将卡特殊召唤
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
	-- 注册效果，使玩家在回合结束前不能特殊召唤非超量怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 注册效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果，禁止特殊召唤非超量怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断该卡是否因效果破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 过滤函数，判断目标怪兽是否表侧表示
function s.desfilter(c)
	return c:IsFaceup()
end
-- 效果的发动条件判断，检查是否有满足条件的场上怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	-- 检查是否有满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的场上怪兽
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，指定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行破坏目标怪兽操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
