--BF T－漆黒のホーク・ジョー
-- 效果：
-- 「黑羽」调整＋调整以外的「黑羽」怪兽1只以上
-- 「黑羽驯鸟师-漆黑之鹰匠·乔」的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只5星以上的鸟兽族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡成为对方的效果的对象时或者成为对方怪兽的攻击对象时，以这张卡以外的自己场上1只「黑羽」怪兽为对象才能发动。那个对象转移为作为正确对象的那只怪兽。
function c81983656.initial_effect(c)
	-- 添加同调召唤手续：需要「黑羽」调整＋调整以外的「黑羽」怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),aux.NonTuner(Card.IsSetCard,0x33),1)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只5星以上的鸟兽族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81983656,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,81983656)
	e1:SetTarget(c81983656.sptg)
	e1:SetOperation(c81983656.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为对方怪兽的攻击对象时，以这张卡以外的自己场上1只「黑羽」怪兽为对象才能发动。那个对象转移为作为正确对象的那只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,81983657)
	e2:SetCondition(c81983656.cbcon)
	e2:SetTarget(c81983656.cbtg)
	e2:SetOperation(c81983656.cbop)
	c:RegisterEffect(e2)
	-- ②：这张卡成为对方的效果的对象时，以这张卡以外的自己场上1只「黑羽」怪兽为对象才能发动。那个对象转移为作为正确对象的那只怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,81983657)
	e3:SetCondition(c81983656.cecon)
	e3:SetTarget(c81983656.cetg)
	e3:SetOperation(c81983656.ceop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中等级5以上、鸟兽族且可以特殊召唤的怪兽
function c81983656.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①（特殊召唤）的发动准备与目标选择
function c81983656.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c81983656.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c81983656.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81983656.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①（特殊召唤）的效果处理
function c81983656.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②（转移攻击对象）的发动条件判定
function c81983656.cbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定此卡是否被选为攻击对象（且非代替破坏等原因）
	return r~=REASON_REPLACE and Duel.GetAttackTarget()==e:GetHandler()
end
-- 过滤自己场上表侧表示的「黑羽」怪兽，且该怪兽必须是攻击者可选择的合法攻击对象
function c81983656.cbfilter(c,at)
	return c:IsFaceup() and c:IsSetCard(0x33) and at:IsContains(c)
end
-- 效果②（转移攻击对象）的发动准备与目标选择
function c81983656.cbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽的所有可选攻击对象
	local at=Duel.GetAttacker():GetAttackableTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81983656.cbfilter(chkc,at) end
	-- 检查自己场上是否存在除这张卡以外、可作为合法攻击对象的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c81983656.cbfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),at) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只除这张卡以外的「黑羽」怪兽作为转移攻击的目标对象
	Duel.SelectTarget(tp,c81983656.cbfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),at)
end
-- 效果②（转移攻击对象）的效果处理
function c81983656.cbop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的转移目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍适用此效果，且攻击怪兽未对该效果免疫
	if tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为选择的目标怪兽
		Duel.ChangeAttackTarget(tc)
	end
end
-- 效果②（转移效果对象）的发动条件判定
function c81983656.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:GetFirst()==e:GetHandler()
end
-- 过滤自己场上表侧表示的「黑羽」怪兽，且该怪兽必须是该连锁效果的合法对象
function c81983656.cefilter(c,ct)
	-- 判定卡片是否为表侧表示的「黑羽」怪兽，且能成为该连锁效果的正确对象
	return c:IsFaceup() and c:IsSetCard(0x33) and Duel.CheckChainTarget(ct,c)
end
-- 效果②（转移效果对象）的发动准备与目标选择
function c81983656.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81983656.cefilter(chkc,ev) end
	-- 检查自己场上是否存在除这张卡以外、可作为该效果正确对象的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c81983656.cefilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),ev) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只除这张卡以外的「黑羽」怪兽作为转移效果的目标对象
	Duel.SelectTarget(tp,c81983656.cefilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),ev)
end
-- 效果②（转移效果对象）的效果处理
function c81983656.ceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的转移目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该连锁效果的对象转移为选择的目标怪兽
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
