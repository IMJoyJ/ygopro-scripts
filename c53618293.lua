--聖蔓の乙女
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的自己场上的植物族怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
-- ②：只要这张卡在怪兽区域存在，自己场上的「圣天树」魔法·陷阱卡以及「圣蔓」魔法·陷阱卡不会成为对方的效果的对象。
function c53618293.initial_effect(c)
	-- 创建效果①，发动条件为对方对己方植物族怪兽发动魔法·陷阱·怪兽效果时
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53618293,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53618293)
	e1:SetCondition(c53618293.negcon)
	e1:SetTarget(c53618293.negtg)
	e1:SetOperation(c53618293.negop)
	c:RegisterEffect(e1)
	-- 创建效果②，使己方场上的「圣天树」和「圣蔓」魔法·陷阱卡不会成为对方效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c53618293.tgtg)
	-- 设置效果②的过滤函数，用于判断目标是否为「圣天树」或「圣蔓」魔法·陷阱卡
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否为己方植物族从额外卡组特殊召唤的怪兽
function c53618293.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件判断，确保是对方发动效果且效果对象包含己方植物族从额外召唤的怪兽
function c53618293.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断效果对象中是否存在己方植物族从额外召唤的怪兽，且该连锁可被无效
	return g and g:IsExists(c53618293.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果①的发动时点判定，检查是否有足够的怪兽区域和手牌可特殊召唤
function c53618293.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，标记将要使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置连锁操作信息，标记将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理函数，将此卡从手卡特殊召唤并使对方效果无效
function c53618293.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，若成功则继续使效果无效
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 效果②的目标过滤函数，判断目标是否为「圣天树」或「圣蔓」魔法·陷阱卡
function c53618293.tgtg(e,c)
	return c:IsSetCard(0x1158,0x2158) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
