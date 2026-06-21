--レッド・ライジング・ドラゴン
-- 效果：
-- 恶魔族调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤时，以自己墓地1只「共鸣者」怪兽为对象才能发动（这个效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤）。那只怪兽特殊召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地2只1星「共鸣者」怪兽为对象才能发动。那2只怪兽特殊召唤。
function c66141736.initial_effect(c)
	-- 添加同调召唤手续：恶魔族调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时，以自己墓地1只「共鸣者」怪兽为对象才能发动（这个效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤）。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66141736,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c66141736.spcon)
	e1:SetCost(c66141736.spcost)
	e1:SetTarget(c66141736.sptg)
	e1:SetOperation(c66141736.spop)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地2只1星「共鸣者」怪兽为对象才能发动。那2只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66141736,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果②的发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c66141736.sptg2)
	e2:SetOperation(c66141736.spop2)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于监控玩家在当前回合内是否特殊召唤过非龙族·暗属性的同调怪兽
	Duel.AddCustomActivityCounter(66141736,ACTIVITY_SPSUMMON,c66141736.counterfilter)
end
-- 计数器过滤函数：过滤出从额外卡组特殊召唤的非龙族·暗属性同调怪兽
function c66141736.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsFaceup())
end
-- 效果①的发动条件：这张卡同调召唤成功
function c66141736.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的Cost处理：检查本回合是否特殊召唤过非龙族·暗属性同调怪兽，并适用“本回合不能从额外卡组特殊召唤龙族·暗属性同调怪兽以外的怪兽”的誓约限制
function c66141736.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合至今为止，玩家是否没有从额外卡组特殊召唤过龙族·暗属性同调怪兽以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(66141736,tp,ACTIVITY_SPSUMMON)==0 end
	-- ①：这张卡同调召唤时，以自己墓地1只「共鸣者」怪兽为对象才能发动（这个效果发动的回合，自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤）。那只怪兽特殊召唤。②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地2只1星「共鸣者」怪兽为对象才能发动。那2只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c66141736.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册不能从额外卡组特殊召唤龙族·暗属性同调怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：禁止从额外卡组特殊召唤非龙族·暗属性的同调怪兽
function c66141736.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果①的特殊召唤目标过滤：自己墓地的「共鸣者」怪兽
function c66141736.spfilter(c,e,tp)
	return c:IsSetCard(0x57) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Target处理：检查怪兽区域空位，并在墓地选择1只「共鸣者」怪兽作为对象
function c66141736.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c66141736.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为对象的「共鸣者」怪兽
		and Duel.IsExistingTarget(c66141736.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地1只「共鸣者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66141736.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，目标为选择的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的Operation处理：将选择的对象怪兽特殊召唤
function c66141736.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的特殊召唤目标过滤：自己墓地的1星「共鸣者」怪兽
function c66141736.spfilter2(c,e,tp)
	return c:IsSetCard(0x57) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target处理：检查怪兽区域空位（需大于1），且墓地有2只1星「共鸣者」怪兽，并选择它们作为对象
function c66141736.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66141736.spfilter2(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有2个或以上可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地（排除这张卡自身）是否存在至少2只可以作为对象的1星「共鸣者」怪兽
		and Duel.IsExistingTarget(c66141736.spfilter2,tp,LOCATION_GRAVE,0,2,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地2只1星「共鸣者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66141736.spfilter2,tp,LOCATION_GRAVE,0,2,2,e:GetHandler(),e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为2，目标为选择的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果②的Operation处理：将选择的2只怪兽特殊召唤
function c66141736.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上可用的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中仍与该效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<2 or g:GetCount()~=2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 将目标卡片组以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
