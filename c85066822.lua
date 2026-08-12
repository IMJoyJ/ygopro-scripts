--ウォーター・ドラゴン
-- 效果：
-- 这张卡不能通常召唤，用「结合术-H2O」的效果才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，场上的炎属性怪兽以及炎族怪兽的攻击力变成0。
-- ②：这张卡被破坏送去墓地时，以自己墓地2只「氢素龙」和1只「氧素龙」为对象才能发动。那些怪兽特殊召唤。
function c85066822.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「结合术-H2O」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，场上的炎属性怪兽以及炎族怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c85066822.atfilter)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏送去墓地时，以自己墓地2只「氢素龙」和1只「氧素龙」为对象才能发动。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85066822,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c85066822.spcon)
	e3:SetTarget(c85066822.sptg)
	e3:SetOperation(c85066822.spop)
	c:RegisterEffect(e3)
end
-- 过滤场上的炎属性或炎族怪兽
function c85066822.atfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_PYRO)
end
-- 检测这张卡是否因破坏而送去墓地
function c85066822.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤墓地中可以特殊召唤的指定卡号的怪兽
function c85066822.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检测与合法性判定
function c85066822.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己场上的怪兽区域空位数是否大于2
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检测自己墓地是否存在至少2只可以特殊召唤的「氢素龙」
		and Duel.IsExistingTarget(c85066822.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp,22587018)
		-- 检测自己墓地是否存在至少1只可以特殊召唤的「氧素龙」
		and Duel.IsExistingTarget(c85066822.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,58071123) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只「氢素龙」作为效果对象
	local g1=Duel.SelectTarget(tp,c85066822.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp,22587018)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「氧素龙」作为效果对象
	local g2=Duel.SelectTarget(tp,c85066822.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,58071123)
	g1:Merge(g2)
	-- 设置特殊召唤3只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,3,0,0)
end
-- 效果②的效果处理（特殊召唤对象怪兽）
function c85066822.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取仍与当前效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 or g:GetCount()>ft then return end
	-- 将目标怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
