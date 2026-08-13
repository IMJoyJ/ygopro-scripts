--聖蔓の乙女
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从额外卡组特殊召唤的自己场上的植物族怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
-- ②：只要这张卡在怪兽区域存在，自己场上的「圣天树」魔法·陷阱卡以及「圣蔓」魔法·陷阱卡不会成为对方的效果的对象。
function c53618293.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：从额外卡组特殊召唤的自己场上的植物族怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。这张卡从手卡特殊召唤，那个效果无效。
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
	-- 只要这张卡在怪兽区域存在，自己场上的「圣天树」魔法·陷阱卡以及「圣蔓」魔法·陷阱卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c53618293.tgtg)
	-- 设置“不能成为效果对象”的效果判定值：当效果发动者不是这张卡的控制者（即对方）时，返回true使保护生效。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：该怪兽必须是tp控制、位于主要怪兽区、表侧表示、种族为植物，且是从额外卡组特殊召唤而来，用于判定对方效果对象是否为满足条件的我方怪兽。
function c53618293.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①效果的发动条件：仅当对方发动取对象效果，且该效果能以我方场上从额外卡组特殊召唤的植物族怪兽为对象，并且该连锁效果可以被无效时才满足。
function c53618293.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 获取当前连锁中对方发动的效果所取的对象卡组，存入局部变量g。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象组g中是否存在至少1张我方场上从额外卡组特殊召唤的植物族怪兽，且该连锁效果可以被无效；两者都满足时发动条件成立。
	return g and g:IsExists(c53618293.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- ①效果发动时的合法性判定：chk==0时，需要我方主要怪兽区有空位且这张卡自身能够被特殊召唤，满足后才能发动。
function c53618293.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用空位，用于即将从手卡特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁包含“无效效果”分类，eg表示对方发动的那个效果所在的卡，供系统处理时的判断。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：本次连锁包含“特殊召唤”分类，对象是这张卡自身（将从手卡特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：先尝试将这张卡从手卡特殊召唤；若特殊召唤成功，则将对方发动的连锁序号ev对应的效果无效化。
function c53618293.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到己方主要怪兽区，若返回值不为0说明特殊召唤成功，继续执行无效化。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将连锁序号ev对应的对方发动的那个效果无效化。
		Duel.NegateEffect(ev)
	end
end
-- ②效果的保护对象筛选：我方场上卡名属于「圣天树」（0x2158）或「圣蔓」（0x1158）的魔法·陷阱卡不会成为对方效果的对象。
function c53618293.tgtg(e,c)
	return c:IsSetCard(0x1158,0x2158) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
