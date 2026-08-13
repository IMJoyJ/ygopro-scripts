--真紅眼の不死竜
-- 效果：
-- 这张卡可以把1只不死族怪兽解放攻击表示上级召唤。
-- ①：这张卡战斗破坏不死族怪兽送去墓地时才能发动。那只不死族怪兽在自己场上特殊召唤。
function c5186893.initial_effect(c)
	-- 对应卡片效果原文中的“这张卡可以把1只不死族怪兽解放攻击表示上级召唤。”，此处定义该召唤规则效果：以1只不死族怪兽为祭品进行上级召唤，并附带召唤条件的判定和处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5186893,0))  --"用1只不死族怪兽解放召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c5186893.otcon)
	e1:SetOperation(c5186893.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 对应卡片效果原文中的“①：这张卡战斗破坏不死族怪兽送去墓地时才能发动。那只不死族怪兽在自己场上特殊召唤。”，此处定义其诱发选发效果的注册及相关的发动条件、发动时选择和效果处理函数。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5186893,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c5186893.spcon)
	e2:SetTarget(c5186893.sptg)
	e2:SetOperation(c5186893.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于筛选可作为上级召唤解放的不死族怪兽，条件为怪兽是不死族，且（由我方控制或是表侧表示），从而可在双方场上选择符合条件的解放素材。
function c5186893.otfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 召唤规则效果的条件判断：若c为空表示询问能否进行规则召唤；否则要求这张卡等级7以上、至少需要1只解放，且场上存在满足otfilter条件的不死族怪兽可供解放。
function c5186893.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有满足otfilter条件的不死族怪兽，作为这次上级召唤可选的解放素材集合。
	local mg=Duel.GetMatchingGroup(c5186893.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定这张卡等级为7以上，所需解放数至少为1，并且通过Duel.CheckTribute确认场上确实存在合法的1只解放素材。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤的操作流程：从可选素材中选出1只不死族怪兽作为祭品，将其设置为这张卡的上级召唤素材，然后解放该素材完成召唤手续。
function c5186893.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 在召唤手续实际执行时，再次检索双方场上所有满足otfilter条件的不死族怪兽，用于让玩家选择解放素材。
	local mg=Duel.GetMatchingGroup(c5186893.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从可选素材中选出1只不死族怪兽，作为这次上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的怪兽解放，解放原因同时包含上级召唤（REASON_SUMMON）和作为召唤素材（REASON_MATERIAL）。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 诱发效果的发劯条件：这张卡战斗破坏不死族怪兽并送去墓地时才能发动，且这张卡仍在场上表侧表示并与那次战斗相关；将战斗破坏的那只不死族怪兽记录为效果的目标。
function c5186893.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次战斗中的攻击怪兽，用于判断哪只怪兽被这张卡战斗破坏。
	local tc=Duel.GetAttacker()
	-- 如果当前这张卡就是攻击怪兽，则它战斗破坏的是攻击对象，因此把目标改为攻击对象，以便正确记录被战斗破坏并送去墓地的不死族怪兽。
	if c==tc then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_ZOMBIE)
end
-- 效果发动时的目标合法检查：确认我方主要怪兽区域有空位，且记录的那只不死族怪兽满足特殊召唤条件，可以被我方特殊召唤。
function c5186893.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	-- 在效果发动的check阶段，检查我方主要怪兽区域是否还有可用的空位，保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	tc:CreateEffectRelation(e)
	-- 向系统登记本次效果包含特殊召唤操作，指定对象为那只被战斗破坏的不死族怪兽，用于连锁处理和发动检视。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果处理阶段：若目标怪兽仍与当前效果保持关联且种族仍为不死族，则将其特殊召唤到我方场上。
function c5186893.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 执行特殊召唤，将目标不死族怪兽以表侧表示（默认攻击表示）特殊召唤到我方主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
