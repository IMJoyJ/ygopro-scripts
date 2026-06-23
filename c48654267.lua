--覇王龍ズァーク－シンクロ・ユニバース
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：把自己场上1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽解放才能发动。这张卡特殊召唤。
-- 【怪兽效果】
-- 调整＋调整以外的暗属性灵摆怪兽1只以上
-- ①：这张卡只要在怪兽区域存在，卡名当作「霸王龙 扎克」使用。
-- ②：这张卡战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时才能发动。从自己的卡组·额外卡组·墓地把最多2只「霸王眷龙」怪兽守备表示特殊召唤。
-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c48654267.initial_effect(c)
	-- 放入「霸王龙 扎克」的卡名列表
	aux.AddCodeList(c,13331639)
	-- 只要在怪兽区域存在，卡名当作「霸王龙 扎克」使用
	aux.EnableChangeCode(c,13331639,LOCATION_MZONE)
	-- 为怪兽添加灵摆属性
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整＋调整以外的暗属性灵摆怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(c48654267.matfilter),1)
	-- ①：把自己场上1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48654267,0))  --"从灵摆区域特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,48654267)
	e1:SetCost(c48654267.pspcost)
	e1:SetTarget(c48654267.psptg)
	e1:SetOperation(c48654267.pspop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时才能发动。从自己的卡组·额外卡组·墓地把最多2只「霸王眷龙」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48654267,1))  --"特殊召唤「霸王眷龙」怪兽"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c48654267.spcon1)
	e2:SetTarget(c48654267.sptg)
	e2:SetOperation(c48654267.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c48654267.spcon2)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48654267,2))  --"在灵摆区域放置"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c48654267.pencon)
	e4:SetTarget(c48654267.pentg)
	e4:SetOperation(c48654267.penop)
	c:RegisterEffect(e4)
end
-- 过滤同调素材：暗属性的灵摆怪兽
function c48654267.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM)
end
-- 过滤场上可作为代价解放的「霸王门」或「霸王眷龙」灵摆怪兽
function c48654267.cfilter(c,tp)
	-- 返回是否属于「霸王门」或「霸王眷龙」且是灵摆怪兽，以及解放后是否有可用的怪兽区格子
	return c:IsSetCard(0x10f8,0x20f8) and c:IsType(TYPE_PENDULUM) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsFaceup() or c:IsControler(tp))
end
-- 从灵摆区特殊召唤效果的发动代价
function c48654267.pspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：场上是否存在满足解放条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c48654267.cfilter,1,nil,tp) end
	-- 给玩家提示信息：请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从场上选择1只满足条件的解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c48654267.cfilter,1,1,nil,tp)
	-- 解放所选的怪兽
	Duel.Release(g,REASON_COST)
end
-- 从灵摆区特殊召唤效果的靶点
function c48654267.psptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 从灵摆区特殊召唤效果的处理
function c48654267.pspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 特殊召唤自身
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 战斗破坏对方怪兽时特殊召唤「霸王眷龙」怪兽效果的发动条件
function c48654267.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and bc~=nil and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 给与对方战斗伤害时特殊召唤「霸王眷龙」怪兽效果的发动条件
function c48654267.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
end
-- 过滤属于「霸王眷龙」且可被特殊召唤的怪兽
function c48654267.spfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 卡在卡组或墓地且场上有可用怪兽区域
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 卡在额外卡组且额外怪兽区有可用空间
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 特殊召唤「霸王眷龙」怪兽效果的发动靶点
function c48654267.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 靶点检查：是否存在可特殊召唤的「霸王眷龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c48654267.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组·额外卡组·墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 过滤额外卡组里里侧表示的融合、同调、超量怪兽
function c48654267.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤额外卡组里的连接怪兽或表侧表示的灵摆怪兽
function c48654267.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 检查选择的特殊召唤怪兽数量及位置限制是否合法
function c48654267.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_GRAVE)<=ft1
		and g:FilterCount(c48654267.exfilter2,nil)<=ft2
		and g:FilterCount(c48654267.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 特殊召唤「霸王眷龙」怪兽效果的处理
function c48654267.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取怪兽区可用格子数
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取额外卡组里侧表示融合、同调、超量怪兽可出场的格子数
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取额外卡组连接怪兽或表侧表示灵摆怪兽可出场的格子数
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取可用的怪兽区域数量
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	-- 计算受其他卡片限制后的额外卡组特殊召唤上限
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if ft1>0 then loc=loc+LOCATION_DECK+LOCATION_GRAVE end
	if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	-- 获取卡组·额外卡组·墓地中所有符合特殊召唤条件的「霸王眷龙」怪兽
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c48654267.spfilter),tp,loc,0,nil,e,tp)
	if sg:GetCount()==0 then return end
	-- 给玩家提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local rg=sg:SelectSubGroup(tp,c48654267.gcheck,false,1,2,ft1,ft2,ft3,ect,ft)
	-- 守备表示特殊召唤选择的怪兽
	Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 在灵摆区域放置效果的发动条件
function c48654267.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 在灵摆区域放置效果的发动靶点
function c48654267.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 靶点检查：自己的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 在灵摆区域放置效果的处理
function c48654267.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
