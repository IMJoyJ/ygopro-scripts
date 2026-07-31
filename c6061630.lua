--マジカル・コンダクター
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或对方把魔法卡发动，给这张卡放置2个魔力指示物。
-- ②：1回合1次，把这张卡的魔力指示物任意数量取除才能发动。把持有和取除数量相同等级的1只魔法师族怪兽从自己的手卡·墓地特殊召唤。
function c6061630.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 注册连锁标记注册效果，用于检测魔法卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 连锁处理：注册连锁标记
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：双方每次发动魔法卡，给这张卡放置2个魔力指示物
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c6061630.acop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，去除这张卡任意数量的魔力指示物才能发动。从自己的手牌·墓地选1只等级与去除数量相同的魔法师族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6061630,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c6061630.sptg)
	e2:SetOperation(c6061630.spop)
	c:RegisterEffect(e2)
end
c6061630.mentioned_counter={
	[0x1]=true,
}
-- 放置魔力指示物处理：在魔法卡连锁处理完毕后放置2个魔力指示物
function c6061630.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 过滤条件：手牌·墓地中等级可用指示物支付且可特召的魔法师族怪兽
function c6061630.filter(c,cc,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()>0 and cc:IsCanRemoveCounter(tp,0x1,c:GetLevel(),REASON_COST)
end
-- 特召效果发动准备：声明并去除魔力指示物，设置特召操作信息
function c6061630.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手牌·墓地是否存在可用指示物支付等级的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c6061630.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler(),e,tp) end
	-- 获取手牌·墓地中可特殊召唤的所有满足条件的魔法师族怪兽
	local g=Duel.GetMatchingGroup(c6061630.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e:GetHandler(),e,tp)
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要去除的魔力指示物数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(6061630,1))  --"请选择要取除的魔力指示物数量"
	-- 玩家声明要去除的魔力指示物数量（对应的怪兽等级）
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x1,lv,REASON_COST)
	e:SetLabel(lv)
	-- 设置连锁操作信息：从手牌·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：手牌·墓地中等级等于声明数值且可特召的魔法师族怪兽
function c6061630.sfilter(c,lv,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevel(lv)
end
-- 特召效果处理：从手牌·墓地选1只指定等级的魔法师族怪兽特殊召唤
function c6061630.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌·墓地选择1只满足等级条件的魔法师族怪兽（受王谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c6061630.sfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
