--テンプレート・スキッパー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为电子界族连接怪兽所连接区的自己场上特殊召唤。
-- ②：自己主要阶段才能发动。从自己的手卡·墓地把1只电子界族怪兽除外。这个回合连接召唤的场合，这张卡可以作为这个效果除外的怪兽的同名卡来成为连接素材。
local s,id,o=GetID()
-- 定义卡片的初始化效果注册函数：创建并注册两个效果，e1为手卡进行的无种类特殊召唤规则效果（对应①，可特殊召唤到电子界族连接怪兽所连接区），e2为在自己主要阶段发动的起动效果（对应②，除外手卡·墓地的电子界族怪兽并赋予同名连接素材效果）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为电子界族连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的手卡·墓地把1只电子界族怪兽除外。这个回合连接召唤的场合，这张卡可以作为这个效果除外的怪兽的同名卡来成为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤出场上表侧表示且为电子界族的连接怪兽，用于计算其指向的连接区域。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- 计算可用特殊召唤区域的函数：将场上所有满足条件的电子界族连接怪兽所连接的区域（zone）合并，并仅保留主怪兽区部分（低5位），返回可用的主怪兽区区域掩码。
function s.checkzone(tp)
	local zone=0
	-- 获取双方场上所有表侧表示的电子界族连接怪兽，用于后续统计它们指向的区域。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历这些连接怪兽，逐只将其箭头指向的区域位并入zone变量。
	for tc in aux.Next(g) do
		zone=zone|tc:GetLinkedZone(tp)
	end
	return zone&0x1f
end
-- 特殊召唤规则的条件函数：c为nil时表示该效果可被正常宣告；否则计算可用zone，并判断该zone在主怪兽区是否有至少一个空位。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.checkzone(tp)
	-- 判定在计算出的连接区（zone）中，玩家tp的主怪兽区是否存在可用的空格，若存在则满足①的特殊召唤条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的值函数，返回(0, zone)，指定这次特殊召唤没有额外召唤类型限制，且只允许进入所计算的连接怪兽连接区（zone）中的空位。
function s.spval(e,c)
	local tp=c:GetControler()
	local zone=s.checkzone(tp)
	return 0,zone
end
-- ②效果选择除外对象的过滤条件：对象必须是电子界族怪兽，并且能够被除外。
function s.rmfilter(c,tc)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemove()
end
-- ②效果的发动目标处理：先检查手卡·墓地是否存在符合条件的电子界族怪兽，通过后设置操作信息，预告这次效果将除外手卡·墓地的1张卡。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法性检查：确认自己手卡·墓地至少存在1只电子界族怪兽（满足s.rmfilter），否则不能发动②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 设置本次连锁的操作信息：效果处理时会从手卡·墓地除外1张卡，类别为除外（CATEGORY_REMOVE），供后续连锁和效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的处理操作：让玩家从自己的手卡·墓地选择1只电子界族怪兽并除外；如果除外成功且这张卡仍在场上表侧表示且作为发动卡与本效果关联，则给这张卡附加“作为连接素材时可以视为被除外怪兽的同名卡”的效果，该效果直到结束阶段为止。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示消息“请选择要除外的卡”，进入选择卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手卡·墓地中选出1只满足条件且不受王家长眠之谷影响的电子界族怪兽（同时排除本卡），作为这次效果要除外的对象。
	local cg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,aux.ExceptThisCard(e))
	if cg:GetCount()==0 then return end
	local code1,code2=cg:GetFirst():GetOriginalCodeRule()
	-- 将所选卡表侧除外，并确认除外操作成功、被除外的卡确实位于除外区，且发动效果的这张卡仍与效果有联系并表侧存在于场上，才继续执行赋予同名卡名效果的处理。
	if Duel.Remove(cg,POS_FACEUP,REASON_EFFECT)~=0 and cg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
		and c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_MONSTER) then
		-- 这个回合连接召唤的场合，这张卡可以作为这个效果除外的怪兽的同名卡来成为连接素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_LINK_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(code1)
		c:RegisterEffect(e1)
		if code2 then
			local e2=e1:Clone()
			e2:SetValue(code2)
			c:RegisterEffect(e2)
		end
	end
end
