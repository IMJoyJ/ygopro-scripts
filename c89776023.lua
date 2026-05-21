--エヴォルド・フォリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只「进化虫」怪兽里侧守备表示特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1张「强制进化」或「突然进化」在自己场上盖放。
-- ③：自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只爬虫类族·恐龙族怪兽解放。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·特召成功时从手卡·墓地里侧特召「进化虫」怪兽；②主要阶段从卡组盖放「强制进化」或「突然进化」；③场上怪兽被破坏时解放场上1只爬虫类族·恐龙族怪兽代替。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只「进化虫」怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组把1张「强制进化」或「突然进化」在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- ③：自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只爬虫类族·恐龙族怪兽解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.desreptg)
	e4:SetValue(s.desrepval)
	e4:SetOperation(s.desrepop)
	c:RegisterEffect(e4)
end
-- 过滤条件：属于「进化虫」字段且可以被里侧守备表示特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x304e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果①的发动准备与合法性检查：检查怪兽区域是否有空位，以及手卡·墓地是否存在满足条件的「进化虫」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在至少1只满足条件的「进化虫」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的实际处理：从手卡·墓地选择1只「进化虫」怪兽里侧守备表示特殊召唤，并给对方确认
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的「进化虫」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若选出了卡，则将其以里侧守备表示特殊召唤到自己场上
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 让对方玩家确认被里侧特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：卡名为「强制进化」或「突然进化」且可以盖放在场上的卡
function s.setfilter(c)
	return c:IsCode(5338223,24362891) and c:IsSSetable()
end
-- 效果②的发动准备与合法性检查：检查卡组中是否存在可盖放的「强制进化」或「突然进化」
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「强制进化」或「突然进化」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的实际处理：从卡组选择1张「强制进化」或「突然进化」在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- 过滤条件：自己场上因战斗或效果将被破坏的怪兽（排除已被代替破坏的情况）
function s.desrepfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤条件：自己场上或手卡中可以作为代替解放的爬虫类族或恐龙族怪兽（排除已被确定破坏的怪兽）
function s.rfilter(c)
	return c:IsRace(RACE_REPTILE+RACE_DINOSAUR)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的发动准备与合法性检查：检查是否有自己场上的怪兽将被破坏，且自己场上或手卡是否有可解放的爬虫类族·恐龙族怪兽
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.desrepfilter,1,nil,tp)
		-- 检查自己场上或手卡是否存在至少1只可解放的爬虫类族·恐龙族怪兽
		and Duel.CheckReleaseGroupEx(tp,s.rfilter,1,REASON_EFFECT,false,nil) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏效果的适用对象：被破坏的怪兽必须是自己场上的怪兽
function s.desrepval(e,c)
	return s.desrepfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的实际处理：选择自己场上或手卡的1只爬虫类族·恐龙族怪兽解放，作为代替不破坏那些怪兽
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要代替破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
	-- 让玩家从场上或手卡选择1只满足条件的爬虫类族·恐龙族怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.rfilter,1,1,REASON_EFFECT,false,nil)
	if #g>0 then
		-- 提示发动代替破坏效果的卡片（显示本卡动画）
		Duel.Hint(HINT_CARD,0,id)
		-- 选中被解放的怪兽并显示选中动画
		Duel.HintSelection(g)
		-- 将选中的怪兽解放，作为代替破坏的处理
		Duel.Release(g,REASON_EFFECT+REASON_REPLACE)
	end
end
