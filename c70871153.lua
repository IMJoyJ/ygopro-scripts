--星辰竜ウルグラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把场上1张魔法·陷阱卡破坏。
-- ②：这张卡在墓地存在的场合，以自己墓地1只魔法师族「星辰」怪兽为对象才能发动。这张卡回到卡组最下面，作为对象的怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（成为融合素材送墓时盖放「星辰」魔陷并可选破坏场上魔陷）和②效果（墓地起动，自身回卡组最下方，回收墓地魔法师族「星辰」怪兽）
function s.initial_effect(c)
	-- ①：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放魔陷"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只魔法师族「星辰」怪兽为对象才能发动。这张卡回到卡组最下面，作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收怪兽"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否作为融合素材送去墓地，作为①效果的发动条件
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤自己卡组中可盖放的「星辰」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动准备，检查自己卡组中是否存在可盖放的「星辰」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足条件的「星辰」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理，从卡组盖放1张「星辰」魔法·陷阱卡，之后可选择破坏场上1张魔法·陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「星辰」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功将选中的卡片在自己场上盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 获取场上所有的魔法·陷阱卡
		local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 如果场上有魔法·陷阱卡存在，询问玩家是否选择进行破坏
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把魔陷破坏？"
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 为选中的要破坏的卡片显示被选为对象的动画效果
			Duel.HintSelection(dg)
			-- 中断当前效果，使后续的破坏处理与盖放处理不视为同时进行
			Duel.BreakEffect()
			-- 因效果破坏选中的魔法·陷阱卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 过滤自己墓地中可以加入手卡的魔法师族「星辰」怪兽
function s.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1c9)
		and c:IsAbleToHand()
end
-- ②效果的发动准备，选择自己墓地1只魔法师族「星辰」怪兽为对象，并确认自身能回到卡组
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=c end
	-- 检查自己墓地是否存在可回收的魔法师族「星辰」怪兽，且此卡自身能回到卡组
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己墓地1只魔法师族「星辰」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置当前连锁的操作信息：将此卡（自身）送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置当前连锁的操作信息：将作为对象的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理，将此卡回到卡组最下面，若成功则将作为对象的怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认此卡仍受效果影响且未受王家之谷限制，将其送回持有者卡组最下面，并确认其已成功回到卡组
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK)
		-- 确认作为对象的怪兽仍受效果影响且未受王家之谷限制
		and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将作为对象的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
	end
end
