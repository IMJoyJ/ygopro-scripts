--RR－レヴォリューション・ファルコン－エアレイド
-- 效果：
-- 鸟兽族6星怪兽×3
-- 这张卡也能把手卡1张「升阶魔法」魔法卡丢弃，在自己场上的5阶以下的「急袭猛禽」超量怪兽上面重叠来超量召唤。
-- ①：这张卡超量召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个攻击力数值的伤害。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从额外卡组把1只「急袭猛禽-革命猎鹰」特殊召唤，把这张卡作为超量素材。
function c79985120.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),6,3,c79985120.ovfilter,aux.Stringid(79985120,0),3,c79985120.xyzop)  --"是否在5阶以下的「急袭猛禽」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79985120,1))  --"对方怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c79985120.descon)
	e1:SetTarget(c79985120.destg)
	e1:SetOperation(c79985120.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合才能发动。从额外卡组把1只「急袭猛禽-革命猎鹰」特殊召唤，把这张卡作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79985120,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c79985120.spcon)
	e2:SetTarget(c79985120.sptg)
	e2:SetOperation(c79985120.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可丢弃的「升阶魔法」魔法卡
function c79985120.cfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 过滤自己场上表侧表示的5阶以下的「急袭猛禽」超量怪兽
function c79985120.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsRankBelow(5)
end
-- 重叠超量召唤时的额外操作（丢弃手卡1张「升阶魔法」魔法卡）
function c79985120.xyzop(e,tp,chk)
	-- 检查手卡中是否存在至少1张满足条件的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c79985120.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张「升阶魔法」魔法卡作为代价丢弃
	Duel.DiscardHand(tp,c79985120.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检查此卡是否为超量召唤成功
function c79985120.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的发动准备，确认对方场上是否存在可作为对象的怪兽，并设置破坏与伤害的操作信息
function c79985120.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏操作的信息，涉及对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害操作的信息，数值为目标怪兽的攻击力，伤害对象为对方玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果①的处理，破坏目标怪兽并给予对方其攻击力数值的伤害
function c79985120.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local dam=tc:GetAttack()
		if dam<0 or tc:IsFacedown() then dam=0 end
		-- 尝试因效果破坏目标怪兽，若成功破坏则继续执行
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给予对方玩家等同于被破坏怪兽攻击力数值的伤害
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
-- 检查此卡是否在自己控制下被对方破坏并送去墓地
function c79985120.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 过滤额外卡组中可以特殊召唤的「急袭猛禽-革命猎鹰」，并确认额外怪兽区域有空位
function c79985120.spfilter(c,e,tp)
	-- 检查卡片是否为「急袭猛禽-革命猎鹰」、是否能特殊召唤，以及额外卡组特召位置是否充足
	return c:IsCode(81927732) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动准备，检查额外卡组是否有可特召的怪兽，且自身是否能作为超量素材叠放，并设置特召和离开墓地的操作信息
function c79985120.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可特殊召唤的「急袭猛禽-革命猎鹰」
	if chk==0 then return Duel.IsExistingMatchingCard(c79985120.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 设置特殊召唤操作的信息，来源为额外卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置卡片离开墓地的操作信息（此卡将作为超量素材）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理，从额外卡组特殊召唤「急袭猛禽-革命猎鹰」，并将此卡作为其超量素材
function c79985120.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「急袭猛禽-革命猎鹰」
	local g=Duel.SelectMatchingCard(tp,c79985120.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 若成功特殊召唤该怪兽，且此卡仍与效果相关联，则继续处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
		-- 将此卡作为超量素材叠放在特殊召唤的怪兽下面
		Duel.Overlay(g:GetFirst(),Group.FromCards(c))
	end
end
