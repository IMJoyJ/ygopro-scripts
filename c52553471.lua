--融合超渦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽为对象才能发动。从手卡·卡组·额外卡组选「元素英雄」怪兽、「新空间侠」怪兽、10星怪兽之内1只给对方观看。这个回合，把作为对象的怪兽作为融合素材的场合，可以当作给人观看的怪兽的同名卡使用。自己的场上或者墓地有「元素英雄 新宇侠」存在的场合，给人观看的怪兽送去墓地。那以外的场合，从手卡给人观看的怪兽回到卡组。
local s,id,o=GetID()
-- 初始化效果，设置卡牌的系列编码和效果类型为发动时点，限制每回合只能发动一次
function s.initial_effect(c)
	-- 记录该卡拥有「元素英雄 新宇侠」的卡号，用于后续判断是否存在于场上或墓地
	aux.AddCodeList(c,89943723)
	-- 为该卡添加「新空间侠」系列编码，用于后续过滤符合条件的怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- 创建效果对象e1，设置其为发动时点、自由连锁、需要选择对象，并限制每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
end
-- 目标过滤函数，判断场上是否存在满足条件的表侧表示怪兽（即可以作为对象的怪兽）
function s.tgfilter(c,tp)
	-- 判断目标怪兽是否为表侧表示且在手牌、卡组或额外卡组中存在符合条件的融合素材
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c,tp)
end
-- 融合素材过滤函数，筛选出符合「元素英雄」、「新空间侠」系列或10星的怪兽
function s.cfilter(c,tc,tp)
	if c:IsCode(tc:GetFusionCode()) then return false end
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x1f) or c:IsSetCard(0x3008) or c:IsLevel(10))
end
-- 效果处理函数，用于选择对象怪兽并设置目标
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	-- 检查是否存在满足条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个满足条件的场上怪兽作为对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
end
-- 判断「元素英雄 新宇侠」是否存在于场上或墓地的过滤函数
function s.neosfilter(c)
	return c:IsCode(89943723) and (c:IsFaceup() or not c:IsOnField())
end
-- 效果发动处理函数，执行效果的主要逻辑
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择给对方确认的融合素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌、卡组或额外卡组中选择一张符合条件的融合素材
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tc,tp):GetFirst()
	if cg==nil then return end
	-- 向对方确认所选的融合素材卡片
	Duel.ConfirmCards(1-tp,cg)
	local code1,code2=cg:GetOriginalCodeRule()
	-- 创建一个效果，使目标怪兽在作为融合素材时可以当作所选融合素材的同名卡使用
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))  --"「融合超涡」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_FUSION_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(code1)
	tc:RegisterEffect(e1)
	if code2 then
		local e2=e1:Clone()
		e2:SetValue(code2)
		tc:RegisterEffect(e2)
	end
	-- 判断是否存在「元素英雄 新宇侠」在场上或墓地
	if Duel.IsExistingMatchingCard(s.neosfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then
		-- 将所选融合素材送去墓地
		Duel.SendtoGrave(cg,REASON_EFFECT)
	elseif cg:IsLocation(LOCATION_HAND) then
		-- 将所选融合素材送回卡组
		Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
