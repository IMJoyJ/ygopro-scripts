--クリスタルクリアウィング・オーバー・シンクロ・ドラゴン
-- 效果：
-- 调整2只以上或者同调怪兽调整＋「幻透翼同调龙」
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：1回合1次，其他卡的效果发动时才能发动。那个发动无效并破坏。这个效果把怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「幻透翼」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 为怪兽添加同调召唤所支持使用的特定素材卡牌代码「幻透翼同调龙」
	aux.AddMaterialCodeList(c,82044279)
	c:EnableReviveLimit()
	-- 为卡片添加同调召唤手续，过滤非调整素材为「幻透翼同调龙」，调整素材为调整怪兽，并进行素材合法性检查
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,82044279),nil,nil,aux.Tuner(nil),1,99,s.syncheck)
	-- 调整2只以上或者同调怪兽调整
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使该卡只能通过同调召唤特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，其他卡的效果发动时才能发动。那个发动无效并破坏。这个效果把怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「幻透翼」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检查同调素材，若是使用2只以上的调整进行同调召唤，则为该卡注册攻击力上升或者其他状态变化的特定效果
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整2只以上或者同调怪兽调整
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤同调非调整素材「幻透翼同调龙」，且需满足其余素材有同调怪兽调整或者调整数量在2只以上，且都不是非调整
function s.mfilter2(c,mg,syncard)
	return c:IsCode(82044279) and (mg:IsExists(Card.IsType,1,c,TYPE_SYNCHRO) or #mg-1>=2) and not mg:IsExists(s.chkfilter,1,c,syncard)
end
-- 过滤不是调整的卡片
function s.chkfilter(c,syncard)
	return not c:IsTuner(syncard)
end
-- 检查同调素材组合是否满足非调整为「幻透翼同调龙」以及对应的调整数量限制条件
function s.syncheck(g,syncard)
	return g:IsExists(s.mfilter2,1,nil,g,syncard)
end
-- 判断无效效果发动条件，这张卡未在战斗中被破坏且该连锁的发动可以被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回这张卡没有在战斗中被破坏，且当前连锁的发动可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置无效并破坏的连锁操作信息，若目标卡片可破坏则注册破坏效果的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为破坏发动的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的发动并破坏，若成功破坏且是怪兽，则该卡在回合结束前上升被破坏怪兽原本攻击力数值
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 若成功使发动无效且成功将目标卡片破坏，并确认被破坏卡片的原本攻击力数值合法
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)~=0 and rc:GetBaseAttack()>=0
		and not rc:IsPreviousLocation(LOCATION_SZONE) and (rc:IsPreviousLocation(LOCATION_MZONE) or rc:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(rc:GetBaseAttack())
		c:RegisterEffect(e1)
	end
end
-- 判断特殊召唤效果的发动条件，须为同调召唤的表侧表示的这张卡因对方从自己场上离开
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤额外卡组中能够特殊召唤的「幻透翼」怪兽且该怪兽可以被特殊召唤，同时检查额外怪兽区域是否有空位
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xff) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且从额外卡组特殊召唤该卡有可用空余位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 特殊召唤效果的靶向检测，确认额外卡组存在可特召的怪兽，并注册特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则返回额外卡组中是否存在符合特召条件的「幻透翼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 在额外卡组中选择1只「幻透翼」怪兽并以表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择需要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「幻透翼」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选取的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
