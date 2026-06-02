--シンクロ・ワンウェイ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地选1只1星调整加入手卡或特殊召唤。
-- ②：这张卡在墓地存在，「废品战士」或者有那个卡名记述的怪兽在自己场上存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 效果初始化注册函数，注册此卡的所有效果
function s.initial_effect(c)
	-- 记录此卡上记载的卡片密码「废品战士」
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
	-- ②：这张卡在墓地存在，「废品战士」或者有那个卡名记述的怪兽在自己场上存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
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
-- 过滤卡组或墓地中满足条件的1星调整怪兽
function s.thfilter(c,e,tp)
	if not (c:IsLevel(1) and c:IsType(TYPE_TUNER)) then return false end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果①的发动准备与条件检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在可以进行操作的1星调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- 效果①的效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择操作卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 在不受王家长眠之谷影响的情况下，选择卡组或墓地中1只满足条件的1星调整怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 检查是否满足将其加入手卡的条件、或者玩家选择将其加入手卡
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入持有者的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认被检索的怪兽
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤场上表侧表示的「废品战士」或者有那个卡名记述的怪兽
function s.cfilter(c)
	-- 检查怪兽是否表侧表示，且卡名为「废品战士」或卡片文本中记载着「废品战士」
	return c:IsFaceup() and (c:IsCode(60800381) or c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,60800381))
end
-- 效果②的发动条件判定（是否自己场上存在「废品战士」或有那个卡名记述的怪兽）
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动准备与条件检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置在效果处理时此卡离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 盖放成功时，为此卡添加在离开场上时被除外的效果
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
