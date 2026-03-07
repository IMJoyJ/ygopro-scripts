--流星竜メテオ・ブラック・ドラゴン
-- 效果：
-- 7星「真红眼」怪兽＋6星龙族怪兽
-- ①：这张卡融合召唤的场合才能发动。从手卡·卡组把1只「真红眼」怪兽送去墓地，给与对方那只怪兽的攻击力一半数值的伤害。
-- ②：这张卡从怪兽区域送去墓地的场合，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c30086349.initial_effect(c)
	-- 添加融合召唤手续，使用满足条件f1与f2的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c30086349.mfilter1,c30086349.mfilter2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。从手卡·卡组把1只「真红眼」怪兽送去墓地，给与对方那只怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30086349,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c30086349.damcon)
	e1:SetTarget(c30086349.damtg)
	e1:SetOperation(c30086349.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡从怪兽区域送去墓地的场合，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30086349,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c30086349.spcon)
	e2:SetTarget(c30086349.sptg)
	e2:SetOperation(c30086349.spop)
	c:RegisterEffect(e2)
end
c30086349.material_setcode=0x3b
-- 过滤函数，用于判断融合素材1是否为7星「真红眼」怪兽
function c30086349.mfilter1(c)
	return c:IsFusionSetCard(0x3b) and c:IsLevel(7)
end
-- 过滤函数，用于判断融合素材2是否为6星龙族怪兽
function c30086349.mfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(6)
end
-- 效果条件函数，判断此卡是否为融合召唤
function c30086349.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 伤害效果的过滤函数，用于选择满足条件的「真红眼」怪兽
function c30086349.damfilter(c)
	return c:IsFusionSetCard(0x3b) and c:GetBaseAttack()>0 and c:IsAbleToGrave()
end
-- 设置连锁处理时的提示信息，包括伤害效果和从卡组/手牌送去墓地的效果
function c30086349.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手牌或卡组中存在满足条件的「真红眼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30086349.damfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理时的提示信息，包括伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 伤害效果的处理函数，选择并送去墓地，然后对对方造成伤害
function c30086349.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「真红眼」怪兽并将其加入到选择组
	local g=Duel.SelectMatchingCard(tp,c30086349.damfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否成功将卡送去墓地且该卡在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 对对方造成伤害，伤害值为所选怪兽攻击力的一半
		Duel.Damage(1-tp,math.floor(g:GetFirst():GetBaseAttack()/2),REASON_EFFECT)
	end
end
-- 效果条件函数，判断此卡是否从怪兽区域送去墓地
function c30086349.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的过滤函数，用于选择满足条件的通常怪兽
function c30086349.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理时的提示信息，包括特殊召唤效果
function c30086349.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30086349.spfilter(chkc,e,tp) end
	-- 检查是否满足发动条件，即场上存在满足条件的通常怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件，即自己墓地存在满足条件的通常怪兽
		and Duel.IsExistingTarget(c30086349.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的通常怪兽并将其设为连锁对象
	local g=Duel.SelectTarget(tp,c30086349.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理时的提示信息，包括特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理函数，将目标怪兽特殊召唤
function c30086349.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以通常形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
