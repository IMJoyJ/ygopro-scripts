--Army of the Haunted
-- 效果：
-- 自己场上有「活死人的呼声」存在，这张卡在自己手卡·墓地存在的场合：可以把这张卡特殊召唤。
-- 这张卡被送去墓地的场合：可以以自己墓地1张「活死人的呼声」为对象；那张卡在自己场上盖放。
-- 「活死人的军势」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括记录关联卡片，以及注册手卡或墓地特召效果、送墓时盖放墓地「活死人的呼声」的效果
function s.initial_effect(c)
	-- 注册该卡记录了「活死人的呼声」这一卡名
	aux.AddCodeList(c,97077563)
	-- 自己场上有「活死人的呼声」存在，这张卡在自己手卡·墓地存在的场合：可以把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地的场合：可以以自己墓地1张「活死人的呼声」为对象；那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「活死人的呼声」
function s.cfilter(c)
	return c:IsCode(97077563) and c:IsFaceup()
end
-- 特殊召唤效果的发动条件判定：判断自己场上是否存在表侧表示的「活死人的呼声」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上是否有表侧表示的「活死人的呼声」存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动合法性判定：检查自己主要怪兽区域是否有空位，以及自身是否可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息：预计特殊召唤此卡本身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的具体处理：若此卡仍与连锁相关且不受王家长眠之谷影响，则以表侧表示特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定此卡是否仍与连锁相关且不受王家长眠之谷效果影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己墓地中可以盖放的「活死人的呼声」
function s.setfilter(c)
	return c:IsCode(97077563) and c:IsSSetable()
end
-- 盖放效果的发动与对象选择：选择自己墓地中1张「活死人的呼声」作为对象，并设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 判定自己墓地是否存在可以被盖放的目标卡片
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择需要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地中的1张「活死人的呼声」作为效果的对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息：预计将选中的卡片移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 盖放效果的具体处理：获取目标卡片，若其与连锁相关且未被王家长眠之谷无效，则将其在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果连锁所指定的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍与连锁相关且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
