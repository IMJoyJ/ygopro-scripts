--ドラグニティ－クーゼ
-- 效果：
-- 把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
-- ①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作4星使用。
-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。
function c29253591.initial_effect(c)
	-- 效果原文内容：把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c29253591.synlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作4星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(c29253591.slevel)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡装备中的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29253591,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c29253591.sptg)
	e3:SetOperation(c29253591.spop)
	c:RegisterEffect(e3)
end
-- 规则层面作用：限制非龙骑兵团怪兽将此卡作为同调素材
function c29253591.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x29)
end
-- 规则层面作用：设置此卡在同调时等级视为4星
function c29253591.slevel(e,c)
	-- 规则层面作用：获取此卡当前等级并确保不超过系统最大参数值
	local lv=aux.GetCappedLevel(e:GetHandler())
	return (4<<16)+lv
end
-- 规则层面作用：判断特殊召唤条件是否满足，包括是否有空场地、是否装备中、是否可特殊召唤
function c29253591.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面作用：检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:GetEquipTarget() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 规则层面作用：执行特殊召唤操作，将此卡从装备区特殊召唤到场上
function c29253591.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面作用：将此卡以正面表示形式特殊召唤到玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
