--ブエリヤベース・ド・ヌーベルズ
-- 效果：
-- 「食谱」卡降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「新式魔厨」卡加入手卡。剩余回到卡组。
-- ②：场上的这张卡成为攻击·效果的对象时才能发动。这张卡和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只2·3星的「新式魔厨」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片的全部效果：调用EnableReviveLimit启用仪式召唤的苏生限制；注册效果①（特殊召唤成功时翻开卡组上方5张并检索1张「新式魔厨」卡）和效果②（成为攻击·效果对象时解放自身和场上1只攻击表示怪兽，从手卡·卡组特殊召唤2·3星「新式魔厨」仪式怪兽），其中②通过克隆e2分别对应“成为效果对象”和“成为攻击对象”两个触发时点。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1张「新式魔厨」卡加入手卡。剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"翻开卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡成为效果的对象时才能发动。这张卡和自己·对方场上1只攻击表示怪兽解放，从手卡·卡组把1只2·3星的「新式魔厨」仪式怪兽特殊召唤。
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
	c:RegisterEffect(e3)
end
-- 效果①的发动条件与对象玩家设定：先检查自己的卡组是否至少有5张，若是则将连锁的对象玩家设为发动者，供后续翻开卡组使用。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己的卡组数量是否不少于5张（不足5张则不能发动①）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	-- 把当前连锁的对象玩家设置为发动者，这样之后处理时就知道翻开谁的卡组。
	Duel.SetTargetPlayer(tp)
end
-- 过滤函数：筛选出卡名含有「新式魔厨」字段且可以加入手卡的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x196) and c:IsAbleToHand()
end
-- 效果①的具体处理：翻开玩家p卡组上方5张卡，从中筛选所有「新式魔厨」卡；若存在可选卡，则询问玩家是否选1张加入手卡，选择后加入手卡并展示给对方确认；最后将剩余卡片放回卡组并洗切。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前记录的对象玩家p（即翻开卡组的玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 将玩家p卡组上方的5张卡翻开并展示给双方确认。
	Duel.ConfirmDecktop(p,5)
	-- 获取玩家p卡组上方5张卡的卡片组对象，便于后续筛选。
	local g=Duel.GetDecktopGroup(p,5)
	local tg=g:Filter(s.thfilter,nil)
	-- 若翻开卡中存在符合条件的「新式魔厨」卡，则弹出“是否选卡加入手卡？”的确认询问。
	if #tg>0 and Duel.SelectYesNo(p,aux.Stringid(id,2)) then  --"是否选卡加入手卡？"
		-- 向玩家p发送“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=tg:Select(p,1,1,nil)
		-- 将选中的卡片以效果原因送入其持有者的手卡（nil表示按持有者返回手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将检索到的卡片展示给对方玩家确认（证明检索了哪张卡）。
		Duel.ConfirmCards(1-p,sg)
	end
	-- 将玩家p的卡组洗切，使剩余未选的卡回到卡组并随机化。
	Duel.ShuffleDeck(p)
end
-- 效果②的发动条件：本次成为攻击对象或效果对象的卡片组中包含这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 解放对象的过滤函数：怪兽可被效果解放、攻击表示，并且将该怪兽与本卡一起解放后自己场上仍留有可用的怪兽区域。
function s.relfilter(c,tp,ec)
	return c:IsReleasableByEffect() and c:IsAttackPos()
		-- 额外判定：把候选怪兽和本卡一起解放后，自己场上仍有足够的怪兽区域，以保证后续特殊召唤能进行。
		and Duel.GetMZoneCount(tp,Group.FromCards(c,ec))>0
end
-- 特殊召唤对象的过滤函数：卡名含「新式魔厨」字段、等级为2或3、类型为仪式怪兽，且可以由当前效果特殊召唤（不检查召唤条件但遵守苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x196) and c:IsLevel(2,3) and c:GetType()&0x81==0x81
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动判定：本卡自身可被解放；双方场上存在1只满足解放条件的攻击表示怪兽；手卡或卡组中存在1只可特殊召唤的2·3星「新式魔厨」仪式怪兽。满足后设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasableByEffect()
		-- 检查场上是否存在1只满足解放条件（可解放、攻击表示、解放后有空位）的怪兽，排除本卡自身。
		and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c)
		-- 检查手卡或卡组中是否存在1只满足条件的「新式魔厨」仪式怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：预计从手卡·卡组特殊召唤1只怪兽，供星尘龙等需要检测特殊召唤的卡使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理：确认本卡仍与效果关联后，选择1只可解放的攻击表示怪兽，将它与本卡一起解放；若解放成功，从手卡·卡组选择1只符合条件的「新式魔厨」仪式怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家发送“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从双方怪兽区选择1只除本卡外满足解放条件的攻击表示怪兽。
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp,c)
	if g:GetCount()==0 then return end
	g:AddCard(c)
	-- 将选中的怪兽和本卡一起解放；若实际解放数量不是2，则效果处理失败并结束。
	if Duel.Release(g,REASON_EFFECT)~=2 then return end
	-- 向玩家发送“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只符合条件的「新式魔厨」仪式怪兽作为要特殊召唤的卡片。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的仪式怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件，但遵守苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
