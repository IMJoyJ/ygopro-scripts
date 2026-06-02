--星辰竜ウルグラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。那之后，可以把场上1张魔法·陷阱卡破坏。
-- ②：这张卡在墓地存在的场合，以自己墓地1只魔法师族「星辰」怪兽为对象才能发动。这张卡回到卡组最下面，作为对象的怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
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
-- 作为融合素材送去墓地的诱发条件判断函数
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤卡组中符合条件的「星辰」魔法·陷阱卡的过滤条件
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动可行性检查函数（Target）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以盖放的「星辰」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的结算操作函数（Operation）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家选择自己卡组中1张符合过滤条件的「星辰」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选择的卡在场上盖放，则继续处理
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 获取场上所有的魔法·陷阱卡
		local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 若场上有魔法·陷阱卡存在，询问玩家是否选择破坏其中一张
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把魔陷破坏？"
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 显示被选作破坏目标的卡片的动画效果
			Duel.HintSelection(dg)
			-- 中断当前效果处理，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的魔法·陷阱卡破坏
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 过滤墓地中魔法师族「星辰」怪兽且能加入手卡的过滤条件
function s.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1c9)
		and c:IsAbleToHand()
end
-- ②效果的发动靶向和对象选择函数（Target）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=c end
	-- 检查自己墓地中是否有作为对象的魔法师族「星辰」怪兽，且自身能够回到卡组
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己墓地中1只作为效果对象的魔法师族「星辰」怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 设置当前连锁的操作信息：将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置当前连锁的操作信息：将目标怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的结算操作函数（Operation）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 若自身依然存在于墓地，确认其不受王家长眠之谷影响并成功送回卡组最下方
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK)
		-- 若目标怪兽依然符合条件且不受王家长眠之谷影响，则处理后续
		and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将作为对象的怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切手卡
		Duel.ShuffleHand(tp)
	end
end
