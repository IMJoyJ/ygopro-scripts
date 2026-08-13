--殺戮聖徒レジーナ
-- 效果：
-- 幻想魔族怪兽＋6星以上的恶魔族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「杀戮圣徒 梦王鸦女」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：「杀戮圣徒 梦王鸦女」以外的「蓟花」卡或「罪宝」卡的效果发动时，以场上最多2张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：添加融合召唤手续、苏生限制，并注册①墓地特殊召唤与②破坏这两个1回合1次的效果。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：素材要求为1只幻想魔族怪兽和1只6星以上的恶魔族怪兽，对应卡面融合素材条件。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),s.mfilter,true)
	c:EnableReviveLimit()
	-- ①：以「杀戮圣徒 梦王鸦女」以外的自己墓地1只幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：「杀戮圣徒 梦王鸦女」以外的「蓟花」卡或「罪宝」卡的效果发动时，以场上最多2张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义融合素材中恶魔族怪兽的筛选条件：等级6以上且种族为恶魔族。
function s.mfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_FIEND)
end
-- 定义①效果可选对象的条件：不是「杀戮圣徒 梦王鸦女」自身、是幻想魔族怪兽且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		and c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的取对象判定：chkc时确认对象在自己墓地且满足spfilter；chk==0时确认主要怪兽区有空位且墓地存在可特殊召唤的幻想魔族目标。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- ①效果发动条件：自己主要怪兽区必须存在可用区域，以便后续特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ①效果发动条件：自己墓地存在至少1只满足条件的幻想魔族怪兽可以作为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡（从墓地选择特殊召唤对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的幻想魔族怪兽作为①效果的对象，并将其与连锁关联。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果包含1次特殊召唤（对象为已选择的墓地怪兽），供发动时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：获取对象怪兽，若其仍与效果关联且不受“王家长眠之谷”影响，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍与此效果关联，并且不受“王家长眠之谷”等墓地效果无效化影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示形式特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果发动条件：连锁中发动的效果来自「蓟花」或「罪宝」系列卡（本卡自身除外），并且本卡不处于战斗破坏确定状态。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(id) and re:GetHandler():IsSetCard(0x1bc,0x19e)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的取对象与发动条件：场上存在至少1张可成为对象的卡，并选择1～2张作为破坏对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	-- ②效果发动条件：自己或对方场上存在至少1张可以成为对象的卡（任意卡）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1～2张卡作为②效果的破坏对象，并建立连锁联系。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置操作信息：本效果将破坏所选择数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：从连锁对象中筛选出仍与效果关联的卡，将它们全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动②效果时选择的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果原因破坏筛选出的对象卡。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
