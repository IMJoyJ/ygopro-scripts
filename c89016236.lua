--ポワレティス・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只4·5星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含仪式召唤限制、①效果（特殊召唤成功时抽卡）、②效果（成为效果/攻击对象时解放并特召）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽1张卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	-- ②：场上的怪兽成为攻击·效果的对象时才能发动。自己场上1只「新式魔厨」怪兽和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只4·5星的「新式魔厨」仪式怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·卡组特殊召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	-- 将被选择为攻击对象时的发动条件设为无条件。
	e3:SetCondition(aux.TRUE)
	c:RegisterEffect(e3)
end
-- ①效果（抽卡）的发动准备与目标确认函数。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果（抽卡）的效果处理函数。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②效果（成为效果对象时）的发动条件判断函数，检查成为对象的卡是否在怪兽区。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0
end
-- 过滤自己场上可被效果解放的「新式魔厨」怪兽，且场上还存在另一只满足解放条件的攻击表示怪兽。
function s.relfilter1(c,tp)
	return c:IsSetCard(0x196) and c:IsReleasableByEffect()
		-- 检查场上是否存在另一只满足解放条件且解放后能腾出怪兽区域的攻击表示怪兽。
		and Duel.IsExistingMatchingCard(s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
end
-- 过滤场上可被效果解放的攻击表示怪兽，且这两只怪兽解放后，自己场上有可用于特殊召唤的怪兽区域。
function s.relfilter2(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 检查将这两只怪兽解放后，自己场上是否有空余的怪兽区域用于特殊召唤。
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- 过滤手卡·卡组中可以特殊召唤的4·5星「新式魔厨」仪式怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(4,5) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果（解放并特召）的发动准备与目标确认函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为解放第一对象的「新式魔厨」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查手卡·卡组中是否存在可特殊召唤的4·5星「新式魔厨」仪式怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果（解放并特召）的效果处理函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只满足条件的「新式魔厨」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.relfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc1=g:GetFirst()
	if not tc1 then return end
	-- 提示玩家选择第二张要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从双方场上选择1只满足条件的攻击表示怪兽（不能与第一只相同）。
	local tc2=Duel.SelectMatchingCard(tp,s.relfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc1,tp,tc1):GetFirst()
	g:AddCard(tc2)
	-- 将选中的2只怪兽解放，若未能成功解放2只则效果处理终止。
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组选择1只满足条件的4·5星「新式魔厨」仪式怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的仪式怪兽无视召唤条件表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
