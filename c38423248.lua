--召喚獣マギストス・セリオン
-- 效果：
-- 「召唤师 阿莱斯特」＋融合·同调·超量·连接怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 初始化卡片效果，注册「召唤师 阿莱斯特」＋融合·同调·超量·连接怪兽的融合召唤手续，以及①②效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤所需素材为1只「召唤师 阿莱斯特」与1只融合·同调·超量·连接怪兽。
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK),1,true,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合，以自己墓地1只融合·同调·超量·连接怪兽和场上1只怪兽为对象才能发动。那些怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只魔法师族·4星怪兽特殊召唤。那之后，可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.material_type=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
-- 协同融合素材过滤函数：检查卡片是否为「召唤师 阿莱斯特」或可替代的融合素材。
function s.sfcfilter(c,fc)
	return c:IsFusionCode(86120751) or c:CheckFusionSubstitute(fc)
end
-- 协同融合检查函数：校验素材组是否包含「召唤师 阿莱斯特」（或代用素材）与1只同调怪兽。
function s.synchro_fusion_check(tp,sg,fc)
	-- 检查素材卡片组中是否同时包含「召唤师 阿莱斯特」（或代用素材）与同调怪兽。
	return aux.gffcheck(sg,s.sfcfilter,fc,Card.IsFusionType,TYPE_SYNCHRO)
end
-- 过滤条件：检查墓地的卡片是否为可除外的融合·同调·超量·连接怪兽。
function s.rmfilter(c,tp)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:IsAbleToRemove()
end
-- ①效果的目标处理函数：检查自己墓地和双方场上的合法对象，分别选取1只后设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：确认自己墓地存在至少1只可除外的融合·同调·超量·连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		-- 确认双方场上存在至少1只可除外的怪兽。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送提示信息，引导玩家选择要除外的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只融合·同调·超量·连接怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 发送提示信息，引导玩家选择要除外的场上怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方场上选择1只可除外的怪兽作为对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：预计将所选定的2只对象怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- ①效果的处理函数：获取仍与连锁保持联系且不受王家长眠之谷影响的怪兽对象，并将其表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍保持联系的全部对象卡片组。
	local g=Duel.GetTargetsRelateToChain()
	-- 过滤出其中不受王家长眠之谷影响且仍为怪兽的对象卡片。
	local tg=g:Filter(aux.NecroValleyFilter(Card.IsType),nil,TYPE_MONSTER)
	if tg:GetCount()>0 then
		-- 将过滤后的对象怪兽以效果表侧表示除外。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：检查融合召唤的这张卡是否从怪兽区因战斗或效果被破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤条件：检查卡片是否为可特殊召唤的魔法师族·4星怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标处理函数：检查自己怪兽区空位及卡组是否存在魔法师族·4星怪兽，并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己怪兽区至少有1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己卡组存在至少1只可特殊召唤的魔法师族·4星怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：从卡组特招1只魔法师族·4星怪兽，随后若魔陷区有空位且自身仍在连锁中，可选将自身装备并提升1000攻击力。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时检查自己怪兽区是否有空位，没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送提示信息，引导玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只魔法师族·4星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将所选怪兽特殊召唤到自己场上，并判断是否特殊召唤成功。
	if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己魔法与陷阱区域是否有空位用于放置装备卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认这张卡仍在连锁中且不受王家长眠之谷影响后，询问玩家是否将这张卡装备给特招怪兽。
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
		-- 中断当前效果处理，使之后的装备与之前的特殊召唤视为不同时处理。
		Duel.BreakEffect()
		-- 将这张卡作为装备卡装备给刚特殊召唤的怪兽，若装备失败则结束处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 可以把这张卡当作攻击力上升1000的装备魔法卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 当作攻击力上升1000的装备魔法卡使用
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制判定函数：限制这张卡只能装备给刚才特殊召唤出来的那只怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
