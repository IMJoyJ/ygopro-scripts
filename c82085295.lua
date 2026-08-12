--魔神儀－ペンシルベル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。「魔神仪-羽毛刀钢笔」以外的卡组1只「魔神仪」怪兽和手卡的这张卡特殊召唤。
-- ②：这张卡从卡组的特殊召唤成功的场合，以自己墓地1只仪式怪兽为对象才能发动。那只怪兽加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
function c82085295.initial_effect(c)
	-- ①：把手卡1只仪式怪兽给对方观看才能发动。「魔神仪-羽毛刀钢笔」以外的卡组1只「魔神仪」怪兽和手卡的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82085295,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82085295)
	e1:SetCost(c82085295.spcost)
	e1:SetTarget(c82085295.sptg)
	e1:SetOperation(c82085295.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组的特殊召唤成功的场合，以自己墓地1只仪式怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82085295,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,82085295)
	e2:SetCondition(c82085295.thcon)
	e2:SetTarget(c82085295.thtg)
	e2:SetOperation(c82085295.thop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c82085295.sumlimit)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「魔神仪-羽毛刀钢笔」以外的「魔神仪」怪兽，且该怪兽可以被特殊召唤
function c82085295.filter(c,e,tp)
	return c:IsSetCard(0x117) and not c:IsCode(82085295) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤手卡中未给对方观看的仪式怪兽
function c82085295.costfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and not c:IsPublic()
end
-- 效果①的发动代价：把手卡1只仪式怪兽给对方观看
function c82085295.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以给对方观看的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82085295.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡中1只未公开的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c82085295.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 重新洗切手卡
	Duel.ShuffleHand(tp)
end
-- 效果①的发动准备：检测自身和卡组的怪兽是否能特殊召唤，且怪兽区域有2个以上的空位
function c82085295.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在可以特殊召唤的「魔神仪」怪兽
		and Duel.IsExistingMatchingCard(c82085295.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果会从手卡和卡组特殊召唤共2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的效果处理：从卡组特殊召唤1只「魔神仪」怪兽，并特殊召唤手卡的这张卡
function c82085295.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己场上的主要怪兽区域空位不足2个，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的「魔神仪」怪兽
	local g=Duel.SelectMatchingCard(tp,c82085295.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将选中的卡组怪兽和手卡的这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：这张卡是从卡组特殊召唤成功的场合
function c82085295.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 过滤墓地中的仪式怪兽，且该怪兽可以加入手卡
function c82085295.thfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 效果②的发动准备：选择墓地1只仪式怪兽作为对象
function c82085295.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c82085295.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c82085295.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择墓地中1只仪式怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82085295.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果会将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的墓地仪式怪兽加入手卡
function c82085295.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果③的限制条件：限制特殊召唤的怪兽来源为额外卡组
function c82085295.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
