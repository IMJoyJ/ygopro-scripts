--V・HERO グラビート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以除外的1只自己的「英雄」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：把这张卡解放，以自己的魔法与陷阱区域2张「幻影英雄」怪兽卡为对象才能发动。那些卡特殊召唤。
function c54185227.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以除外的1只自己的「英雄」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54185227,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,54185227)
	e1:SetTarget(c54185227.thtg)
	e1:SetOperation(c54185227.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放，以自己的魔法与陷阱区域2张「幻影英雄」怪兽卡为对象才能发动。那些卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54185227,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,54185228)
	e3:SetCost(c54185227.spcost)
	e3:SetTarget(c54185227.sptg)
	e3:SetOperation(c54185227.spop)
	c:RegisterEffect(e3)
end
-- 过滤除外状态的、表侧表示的「英雄」怪兽且可以加入手卡
function c54185227.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备与对象选择
function c54185227.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c54185227.thfilter(chkc) end
	-- 检查除外区是否存在至少1只符合条件的「英雄」怪兽
	if chk==0 then return Duel.IsExistingTarget(c54185227.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外区1只符合条件的「英雄」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54185227.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁信息，该效果包含将选中的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理：将作为对象的怪兽加入手卡
function c54185227.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡因效果加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的解放代价处理
function c54185227.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己魔法与陷阱区域（不含场地区）表侧表示的、可以特殊召唤的「幻影英雄」怪兽卡
function c54185227.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x5008) and c:GetSequence()<5 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与对象选择，包含怪兽区域空格和特殊召唤限制的检测
function c54185227.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c54185227.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查魔法与陷阱区域是否存在2张符合条件的「幻影英雄」怪兽卡
		and Duel.IsExistingTarget(c54185227.spfilter,tp,LOCATION_SZONE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择魔法与陷阱区域2张符合条件的「幻影英雄」怪兽卡作为效果对象
	local g=Duel.SelectTarget(tp,c54185227.spfilter,tp,LOCATION_SZONE,0,2,2,nil,e,tp)
	-- 设置连锁信息，该效果包含将选中的2张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- ②效果的处理：将作为对象的「幻影英雄」怪兽卡特殊召唤
function c54185227.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中被选择的所有对象卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将符合条件的卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
