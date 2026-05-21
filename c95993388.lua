--地帝家臣ランドローブ
-- 效果：
-- 「地帝家臣 兰罗布」的①②的效果1回合各能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合，以「地帝家臣 兰罗布」以外的自己墓地1只攻击力800/守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。
function c95993388.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,95993388)
	e1:SetTarget(c95993388.sptg)
	e1:SetOperation(c95993388.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为上级召唤而被解放的场合，以「地帝家臣 兰罗布」以外的自己墓地1只攻击力800/守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,95993389)
	e2:SetCondition(c95993388.thcon)
	e2:SetTarget(c95993388.thtg)
	e2:SetOperation(c95993388.thop)
	c:RegisterEffect(e2)
end
-- 过滤对方场上表侧表示且可以变成里侧表示的怪兽
function c95993388.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①的发动准备：检查自身能否特殊召唤、对方场上是否存在符合条件的怪兽，并选择对象
function c95993388.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c95993388.filter(chkc) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否存在可以变成里侧守备表示的表侧表示怪兽
		and Duel.IsExistingTarget(c95993388.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95993388.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的处理：特殊召唤自身，将对象怪兽变成里侧守备表示，并适用不能从额外卡组特殊召唤的限制
function c95993388.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有空位且自身卡片是否仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡从手卡表侧表示特殊召唤
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 将作为对象的怪兽变成里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
	-- 这个回合，自己不能从额外卡组把怪兽特殊召唤。 / ②：这张卡为上级召唤而被解放的场合，以「地帝家臣 兰罗布」以外的自己墓地1只攻击力800/守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95993388.splimit)
	-- 注册不能从额外卡组特殊召唤怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的来源为额外卡组
function c95993388.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 检查这张卡是否是因为上级召唤而被解放
function c95993388.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 过滤自己墓地中除「地帝家臣 兰罗布」以外、攻击力800且守备力1000的可以加入手牌的怪兽
function c95993388.thfilter(c)
	return c:IsAttack(800) and c:IsDefense(1000) and not c:IsCode(95993388) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查墓地中是否存在符合条件的怪兽，并选择对象
function c95993388.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c95993388.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c95993388.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95993388.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：将作为对象的墓地怪兽加入手牌
function c95993388.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
