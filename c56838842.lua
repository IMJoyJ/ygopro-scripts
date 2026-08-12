--デモン・ピース・ゴーレム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有恶魔族调整存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这张卡的等级下降最多2星。
-- ③：这张卡作为「红莲魔龙」或者有那个卡名记述的同调怪兽的同调素材送去墓地的场合，以自己墓地1只4星以下的恶魔族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤、特殊召唤成功时下降等级、作为特定同调素材送墓时特殊召唤墓地恶魔族怪兽的效果。
function s.initial_effect(c)
	-- 将「红莲魔龙」的卡片密码加入该卡的关联卡片列表中，用于后续效果检测。
	aux.AddCodeList(c,70902743)
	-- ①：这张卡在手卡存在，自己场上有恶魔族调整存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。这张卡的等级下降最多2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"下降等级"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为「红莲魔龙」或者有那个卡名记述的同调怪兽的同调素材送去墓地的场合，以自己墓地1只4星以下的恶魔族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示存在的恶魔族调整怪兽。
function s.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上存在恶魔族调整怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的恶魔族调整怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：将手卡中的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动准备与合法性检测（检查自身等级是否在2星以上）。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(2) end
end
-- 效果②的处理：让这张卡的等级下降最多2星。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() and not c:IsImmuneToEffect(e) and c:IsLevelAbove(2) then
		-- 这张卡的等级下降最多2星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		local lv=1
		if c:IsLevelAbove(3) then
			-- 让玩家选择下降1星或下降2星，并返回对应的数值。
			lv=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))+1  --"下降1星/下降2星"
		end
		e1:SetValue(0-lv)
		c:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：作为同调素材送去墓地，且该同调怪兽是「红莲魔龙」或记述了「红莲魔龙」卡名的怪兽。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		-- 检查作为素材召唤出的同调怪兽是否是「红莲魔龙」或在其卡名记述中包含「红莲魔龙」。
		and aux.IsCodeOrListed(e:GetHandler():GetReasonCard(),70902743)
end
-- 过滤条件：墓地中可以守备表示特殊召唤的4星以下的恶魔族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果③的发动准备与目标选择（选择墓地1只4星以下的恶魔族怪兽为对象）。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的恶魔族怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的恶魔族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息：将选中的目标怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的处理：将作为对象的墓地怪兽守备表示特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与连锁相关，并应用王家长眠之谷的过滤检测。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
