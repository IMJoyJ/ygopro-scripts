--マシンナーズ・パゼストレージ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以「机甲魔化仓库兵」以外的自己墓地1只「机甲」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
-- ②：以这张卡以外的自己场上1只「机甲」怪兽和对方场上1张魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
function c85136114.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以「机甲魔化仓库兵」以外的自己墓地1只「机甲」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85136114,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,85136114)
	e1:SetTarget(c85136114.sptg)
	e1:SetOperation(c85136114.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己场上1只「机甲」怪兽和对方场上1张魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85136114,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,85136115)
	e3:SetTarget(c85136114.thtg)
	e3:SetOperation(c85136114.thop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中「机甲魔化仓库兵」以外、可以守备表示特殊召唤的「机甲」怪兽
function c85136114.spfilter(c,e,tp)
	return c:IsSetCard(0x36) and not c:IsCode(85136114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备，确认怪兽区域有空位并选择自己墓地1只符合条件的「机甲」怪兽作为对象
function c85136114.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85136114.spfilter(chkc,e,tp) end
	-- 检查自身怪兽区域是否有空位，以及自己墓地是否存在符合条件的「机甲」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c85136114.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「机甲」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85136114.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理，将作为对象的怪兽守备表示特殊召唤，并使其在本回合不能发动效果
function c85136114.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选定的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍存在于墓地，并将其以表侧守备表示特殊召唤（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 过滤自己场上表侧表示、可以回到手卡的「机甲」怪兽
function c85136114.thfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x36) and c:IsAbleToHand()
end
-- 过滤对方场上可以回到手卡的魔法·陷阱卡
function c85136114.thfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备，选择自己场上1只「机甲」怪兽和对方场上1张魔法·陷阱卡作为对象
function c85136114.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在除自身以外的「机甲」怪兽，以及对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c85136114.thfilter1,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.IsExistingTarget(c85136114.thfilter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手卡的自己场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只「机甲」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c85136114.thfilter1,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 提示玩家选择要返回手卡的对方场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象
	local g2=Duel.SelectTarget(tp,c85136114.thfilter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁信息，表明该效果包含将2张卡送回手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果②的处理，将作为对象的卡片送回持有者的手卡
function c85136114.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些卡片送回持有者的手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
