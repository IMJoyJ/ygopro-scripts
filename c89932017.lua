--シンクロ・ワンウェイ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地选1只1星调整加入手卡或特殊召唤。
-- ②：这张卡在墓地存在，「废品战士」或者有那个卡名记述的怪兽在自己场上存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的效果①（发动）和效果②（盖放）
function s.initial_effect(c)
	-- 在卡片关联列表中添加「废品战士」的卡片密码
	aux.AddCodeList(c,60800381)
	-- ①：从自己的卡组·墓地选1只1星调整加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，「废品战士」或者有那个卡名记述的怪兽在自己场上存在的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选卡组或墓地中可以加入手卡或特殊召唤的1星调整怪兽
function s.thfilter(c,e,tp)
	if not (c:IsLevel(1) and c:IsType(TYPE_TUNER)) then return false end
	-- 获取玩家场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果①的发动准备：检查卡组或墓地中是否存在满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组或墓地中是否存在至少1只满足条件的1星调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- 效果①的效果处理：选择1只满足条件的怪兽，并根据情况将其加入手卡或特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的系统提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组或墓地中选择1只满足条件的怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取当前玩家场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否加入手卡：若能加入手卡，且（不能特召、无可用怪兽区域、或玩家在选项中选择加入手卡）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示并确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：筛选场上表侧表示的「废品战士」或记述了「废品战士」卡名的怪兽
function s.cfilter(c)
	-- 检查卡片是否为表侧表示的「废品战士」或其效果文本中记述了「废品战士」的怪兽
	return c:IsFaceup() and (c:IsCode(60800381) or c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,60800381))
end
-- 效果②的发动条件：检查自己场上是否存在满足条件的怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「废品战士」或记述了该卡名的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动准备：检查这张卡是否可以盖放，并设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置效果处理的操作信息：将1张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将这张卡在场上盖放，并适用离开场上时除外的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地（不受王家长眠之谷影响）且成功在场上盖放
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
