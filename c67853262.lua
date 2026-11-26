--神聖なる魔術師
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。那之后，可以从卡组把1只「圣魔术师」或「神圣魔术师」里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册反转诱发选发效果（1回合1次，回收己方墓地1张魔法卡并可选从卡组里侧守备表示特召「圣魔术师」或「神圣魔术师」）
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。 ①：这张卡反转的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。那之后，可以从卡组把1只「圣魔术师」或「神圣魔术师」里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：检查卡片是否为魔法卡且可以加入手卡
function s.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 发动检测、取对象及连锁信息设置：确认己方墓地存在可加入手卡的魔法卡，选择1张作为对象并登记加入手卡操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 发动条件检查：确认己方墓地存在至少1张可加入手卡的魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向己方提示选择要加入手卡的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从己方墓地选择1张魔法卡作为连锁对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记连锁的加入手卡操作信息，预计将所选墓地魔法卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 筛选条件：检查卡片是否为「圣魔术师」或「神圣魔术师」，且能以里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(31560081,id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理流程：将作为对象的墓地魔法卡加入手卡；若成功加入手卡且己方怪兽区有空位，则可选从卡组里侧守备表示特召1只「圣魔术师」或「神圣魔术师」并向对方展示
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的己方墓地魔法卡对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在连锁中并以效果将其加入手卡，判断是否操作成功
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		-- 获取己方卡组中可里侧守备表示特殊召唤的「圣魔术师」或「神圣魔术师」卡片组
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检查己方主要怪兽区有空位且卡组中存在满足条件的怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0
			-- 询问己方是否从卡组里侧守备表示特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组特殊召唤？"
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断效果处理，使后续的特殊召唤与前面的加入手卡视为不同时处理
			Duel.BreakEffect()
			-- 将所选怪兽以里侧守备表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 向对方展示里侧特殊召唤的怪兽以确认卡名合法
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
