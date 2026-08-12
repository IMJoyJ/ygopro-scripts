--超魔導戦士－マスター・オブ・カオス
-- 效果：
-- 「黑魔术师」＋「混沌」仪式怪兽
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以自己墓地1只光·暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把自己场上的光·暗属性怪兽各1只解放才能发动。对方场上的怪兽全部除外。
-- ③：融合召唤的这张卡被战斗·效果破坏的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
function c85059922.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「黑魔术师」和1只「混沌」仪式怪兽
	aux.AddFusionProcCodeFun(c,46986414,c85059922.matfilter,1,true,true)
	-- ①：这张卡融合召唤的场合，以自己墓地1只光·暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85059922,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,85059922)
	e1:SetCondition(c85059922.spcon)
	e1:SetTarget(c85059922.sptg)
	e1:SetOperation(c85059922.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上的光·暗属性怪兽各1只解放才能发动。对方场上的怪兽全部除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85059922,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85059923)
	e2:SetCost(c85059922.remcost)
	e2:SetTarget(c85059922.remtg)
	e2:SetOperation(c85059922.remop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被战斗·效果破坏的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85059922,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,85059924)
	e3:SetCondition(c85059922.thcon)
	e3:SetTarget(c85059922.thtg)
	e3:SetOperation(c85059922.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：属于「混沌」系列且是仪式怪兽
function c85059922.matfilter(c)
	return c:IsSetCard(0xcf) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL)
end
-- 效果①的发动条件：这张卡是融合召唤成功的场合
function c85059922.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的特殊召唤对象过滤条件：自己墓地的光·暗属性且可以特殊召唤的怪兽
function c85059922.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查与选择目标）：检查怪兽区域是否有空位，并选择自己墓地1只光·暗属性怪兽作为对象
function c85059922.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85059922.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的光·暗属性怪兽
		and Duel.IsExistingTarget(c85059922.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的光·暗属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85059922.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：包含特殊召唤操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将选择的墓地怪兽特殊召唤
function c85059922.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个（也是唯一一个）对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的解放Cost过滤条件：自己场上的光·暗属性怪兽，且对方场上存在可除外的怪兽
function c85059922.remcostfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查对方场上是否存在至少1张可以被除外的怪兽（排除自身作为Cost的情况）
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,c)
end
-- 效果②的发动代价（Cost）：解放自己场上的光·暗属性怪兽各1只
function c85059922.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可解放的、且满足Cost过滤条件的光·暗属性怪兽
	local g=Duel.GetReleaseGroup(tp):Filter(c85059922.remcostfilter,nil,tp)
	-- 检查是否能从可解放怪兽中选出光属性和暗属性怪兽各1只
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择光属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 扣除代替解放效果的使用次数（如暗影敌托邦等效果）
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的2只怪兽作为发动代价（Cost）解放
	Duel.Release(sg,REASON_COST)
end
-- 效果②的发动准备（检查与信息设置）：检查对方场上是否有可除外的怪兽，并设置除外操作信息
function c85059922.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以被除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁处理信息：包含除外操作，对象为对方场上的所有可除外怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果②的效果处理：将对方场上的怪兽全部除外
function c85059922.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上所有可以被除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	-- 将获取到的怪兽全部以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 效果③的发动条件：融合召唤的这张卡在怪兽区域被战斗或效果破坏的场合
function c85059922.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 效果③的回收对象过滤条件：自己墓地的魔法卡且能加入手卡
function c85059922.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果③的发动准备（检查与选择目标）：检查自己墓地是否有魔法卡，并选择其中1张作为对象
function c85059922.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85059922.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingTarget(c85059922.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c85059922.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：包含加入手牌操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将选择的墓地魔法卡加入手卡
function c85059922.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个（也是唯一一个）对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
