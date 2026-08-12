--転生炎獣Jジャガー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡在墓地存在，自己场上有「转生炎兽」连接怪兽存在的场合，以「转生炎兽 灯火美洲豹」以外的自己墓地1只「转生炎兽」怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡在作为自己的「转生炎兽」连接怪兽所连接区的自己场上特殊召唤。
function c56003780.initial_effect(c)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「转生炎兽」连接怪兽存在的场合，以「转生炎兽 灯火美洲豹」以外的自己墓地1只「转生炎兽」怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡在作为自己的「转生炎兽」连接怪兽所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56003780,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,56003780)
	e2:SetCondition(c56003780.spcon)
	e2:SetTarget(c56003780.sptg)
	e2:SetOperation(c56003780.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「转生炎兽」连接怪兽
function c56003780.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- 效果②的发动条件：自己场上存在「转生炎兽」连接怪兽
function c56003780.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件的卡（表侧表示的「转生炎兽」连接怪兽）
	return Duel.IsExistingMatchingCard(c56003780.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己墓地「转生炎兽 灯火美洲豹」以外的「转生炎兽」怪兽且能回到卡组
function c56003780.tdfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and not c:IsCode(56003780) and c:IsAbleToDeck()
end
-- 效果②的发动准备（target阶段）：检查是否满足发动条件、计算可特殊召唤的区域、选择要回到卡组的墓地怪兽作为对象并设置操作信息
function c56003780.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c56003780.tdfilter(chkc) end
	-- 获取自己场上所有表侧表示的「转生炎兽」连接怪兽
	local g=Duel.GetMatchingGroup(c56003780.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()<=0 then return false end
	local zone=0
	-- 遍历这些「转生炎兽」连接怪兽
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	zone=bit.band(zone,0x1f)
	-- 在chk==0（检查是否可行）时，判断在连接端指向的区域是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		-- 并且自己墓地存在至少1只可以作为对象的「转生炎兽」怪兽
		and Duel.IsExistingTarget(c56003780.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「转生炎兽」怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c56003780.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的墓地怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（operation阶段）：将对象怪兽送回卡组，并将这张卡特殊召唤到连接端
function c56003780.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍与效果相关，则将其送回卡组并洗牌；若成功回到卡组（或额外卡组）且这张卡仍与效果相关，则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and e:GetHandler():IsRelateToEffect(e) then
		-- 重新获取自己场上表侧表示的「转生炎兽」连接怪兽以重新计算连接端区域
		local g=Duel.GetMatchingGroup(c56003780.filter,tp,LOCATION_MZONE,0,nil)
		if g:GetCount()<=0 then return end
		local zone=0
		-- 遍历这些连接怪兽以合并它们指向的区域
		for tc in aux.Next(g) do
			zone=bit.bor(zone,tc:GetLinkedZone(tp))
		end
		zone=bit.band(zone,0x1f)
		if zone==0 then return end
		-- 将这张卡在计算出的连接端区域以表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
