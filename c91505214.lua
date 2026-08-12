--トリックスター・ナルキッス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方受到效果伤害的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，每次对方把手卡·墓地的怪兽的效果发动，给与对方200伤害。
function c91505214.initial_effect(c)
	-- ①：对方受到效果伤害的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91505214,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,91505214)
	e1:SetCondition(c91505214.sumcon)
	e1:SetTarget(c91505214.sumtg)
	e1:SetOperation(c91505214.sumop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方把手卡·墓地的怪兽的效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c91505214.regop)
	c:RegisterEffect(e2)
	-- 给与对方200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c91505214.damcon)
	e3:SetOperation(c91505214.damop)
	c:RegisterEffect(e3)
end
-- 判断伤害原因是否为效果，且受伤害者是否为对方
function c91505214.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep~=tp
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位及自身是否可特殊召唤
function c91505214.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，将这张卡特殊召唤
function c91505214.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 对方在手卡或墓地发动怪兽效果时，为这张卡注册一个在连锁内有效的标记
function c91505214.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_MONSTER) and (re:GetActivateLocation()==LOCATION_GRAVE or re:GetActivateLocation()==LOCATION_HAND) then
		e:GetHandler():RegisterFlagEffect(91505214,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- 检查是否满足伤害条件：对方在手卡或墓地发动了怪兽效果，且这张卡带有对应标记
function c91505214.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(91505214)~=0 and (re:GetActivateLocation()==LOCATION_GRAVE or re:GetActivateLocation()==LOCATION_HAND)
end
-- 执行伤害处理，给与对方200点效果伤害
function c91505214.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 在游戏界面上显示这张卡的卡片提示
	Duel.Hint(HINT_CARD,0,91505214)
	-- 给与对方200点效果伤害
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
