--カオス・デーモン－混沌の魔神－
-- 效果：
-- 光属性调整＋调整以外的暗属性怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升2000。
-- ②：这张卡可以向对方怪兽全部各作1次攻击，这张卡战斗破坏的怪兽不去墓地而除外。
-- ③：这张卡因对方从场上离开的场合才能发动。「混沌之魔神」以外的1只「混沌」同调怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册混沌之魔神的同调召唤手续及全部效果：光属性调整＋调整以外的暗属性怪兽1只以上；本回合有卡被除外时攻击力上升2000；可向对方怪兽全部各作1次攻击，且战斗破坏的怪兽不去墓地而除外；因对方从场上离开时可从额外卡组特殊召唤「混沌之魔神」以外的「混沌」同调怪兽；并注册全局除外监视效果以支持①的判定。
function s.initial_effect(c)
	-- 设置同调召唤手续：以1只光属性调整＋调整以外暗属性怪兽1只以上为素材进行同调召唤。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetValue(2000)
	c:RegisterEffect(e1)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏的怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡因对方从场上离开的场合才能发动。「混沌之魔神」以外的1只「混沌」同调怪兽从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升2000。③：这张卡因对方从场上离开的场合才能发动。「混沌之魔神」以外的1只「混沌」同调怪兽从额外卡组特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.checkop)
		-- 将监视除外事件的全局连续效果ge1注册到决斗中，使每次有卡被除外时都执行checkop。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义checkop：当任意卡被除外时，为本回合设置一个“已有卡被除外”的标识，供①攻击力上升效果使用。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家0注册一个“本回合已有卡被除外”的标识，该标识在结束阶段重置。
	Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
end
-- 定义①效果的适用条件：检查本回合是否已经存在卡被除外的标识。
function s.rmcon(e)
	-- 返回玩家0的“已有卡被除外”标识数量是否大于0，即本回合是否已有卡被除外。
	return Duel.GetFlagEffect(0,id)>0
end
-- 定义③效果的发动条件：这张卡离场前在场上且原本由自己控制，并且是因为对方的原因（对方的卡或效果）导致离场。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 定义③效果可特殊召唤的怪兽筛选条件：额外卡组中「混沌之魔神」以外的「混沌」同调怪兽，且能被该效果特殊召唤，并有足够的额外卡组特召空格。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xcf) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 追加检查：将候选怪兽c从额外卡组特殊召唤时，tp方需要有至少1个可用的怪兽区域空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 定义③效果的发动目标：额外卡组存在符合条件的「混沌」同调怪兽时才能发动，并设置本次效果的操作信息为特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：额外卡组中是否存在至少1只满足条件的「混沌」同调怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本效果为从额外卡组特殊召唤1只怪兽（不取对象，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义③效果的处理：选择1只符合条件的「混沌」同调怪兽，从额外卡组特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1张满足筛选条件的「混沌」同调怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「混沌」同调怪兽以表侧攻击表示特殊召唤到tp的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
