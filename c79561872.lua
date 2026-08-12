--わくどきメルフィーズ
-- 效果：
-- 「童话动物」怪兽＋兽族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以自己场上的「童话动物」卡和对方场上的卡各相同数量为对象才能发动。那些卡回到手卡。
-- ②：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合，以自己墓地1只兽族怪兽为对象才能发动。这张卡的等级下降2星，作为对象的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：以「童话动物」怪兽和兽族怪兽各1只作为素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x146),aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),true)
	-- ①：这张卡融合召唤的场合，以自己场上的「童话动物」卡和对方场上的卡各相同数量为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合，以自己墓地1只兽族怪兽为对象才能发动。这张卡的等级下降2星，作为对象的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCondition(s.spcon2)
	c:RegisterEffect(e4)
end
-- 判定是否是融合召唤成功时发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤自己场上可以作为效果对象并可以回到手牌的表侧表示的「童话动物」卡
function s.thfilter1(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
		and c:IsFaceup() and c:IsSetCard(0x146)
end
-- 过滤对方场上可以作为效果对象并可以回到手牌的卡
function s.thfilter2(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- 回手牌效果的靶子判定与效果对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有符合条件的表侧表示「童话动物」卡
	local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	-- 获取对方场上所有符合条件的卡片组
	local g2=Duel.GetMatchingGroup(s.thfilter2,tp,0,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #g1>0 and #g2>0 end
	-- 给玩家发送选择返回手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从双方场上选择相同数量的卡片
	local sg=aux.SelectSameCount(tp,g1,g2)
	-- 将选择 of 卡片保存为该效果的连锁对象
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息为将所选对象卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 融合召唤成功时将双方场上对象卡片返回手牌的实际处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍存在于场上的对象卡片组
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	-- 因效果将目标卡片送回持有者的手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
-- 过滤是否是特定玩家召唤·特殊召唤的怪兽
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 判定是否是对方玩家进行了通常召唤·特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 判定攻击方怪兽的控制权是否是对方玩家
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回本次战斗中发起攻击的怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤墓地中可以特殊召唤的兽族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 降星特召墓地兽族怪兽效果的靶子判定与效果对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 判定自己主要怪兽区域是否还有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsLevelAbove(3)
		-- 判定自己墓地是否存在可特殊召唤的兽族怪兽作为对象
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只兽族怪兽作为效果处理的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 自身等级下降并特殊召唤墓地兽族怪兽的实际处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsLevelAbove(3) and not c:IsImmuneToEffect(e) then
		-- 这张卡的等级下降2星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(-2)
		c:RegisterEffect(e1)
		-- 获取连锁中选择的第1个效果目标怪兽
		local tc=Duel.GetFirstTarget()
		-- 判定目标怪兽是否仍与连锁关联且不受王家长眠之谷的影响
		if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
			-- 将目标怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
