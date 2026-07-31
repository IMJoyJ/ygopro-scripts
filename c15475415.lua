--エーリアン・ドッグ
-- 效果：
-- 自己对名字带有「外星」的怪兽的召唤成功时，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，给对方场上表侧表示存在的怪兽放置2个A指示物。
function c15475415.initial_effect(c)
	-- 效果 e1 的整体定义与相关子函数（spcon, sptg, spop），对应卡片效果的原文第一部分：'自己对名字带有「外星」的怪兽的召唤成功时，这张卡可以从手牌特殊召唤。'
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15475415,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15475415.spcon)
	e1:SetTarget(c15475415.sptg)
	e1:SetOperation(c15475415.spop)
	c:RegisterEffect(e1)
	-- 效果 e2 的整体定义与相关子函数（ctcon, ctop），对应卡片效果的原文第二部分：'这个效果特殊召唤成功时，给对方场上表侧表示存在的怪兽放置2个A指示物。'
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15475415,1))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c15475415.ctcon)
	e2:SetOperation(c15475415.ctop)
	c:RegisterEffect(e2)
end
c15475415.counter_add_list={0x100e}
c15475415.mentioned_counter={
	[0x100e]=true,
}
-- 效果 e1 的条件判断函数 spcon，确认发动者是否为特召方且召唤的怪兽属于名字带有「外星」的卡组（Set ID 0xc）。
function c15475415.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSetCard(0xc)
end
-- 效果 e1 的目标判断与操作信息设置函数 sptg，检查场上是否有可用的怪兽区位置且手牌中的这张卡满足特殊召唤条件。
function c15475415.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- sptg 内部的具体格子数检查逻辑，确认玩家场上的主要怪兽区域（LOCATION_MZONE）是否有空位可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- SetOperationInfo 调用行，设置操作信息告知系统当前连锁操作中涉及的是 CATEGORY_SPECIAL_SUMMON 分类，目标为手牌中的这张卡（e1），数量为 1 张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果 e1 的操作处理函数 spop，在满足条件且目标确定后，将手牌中的这张卡特殊召唤到场上。
function c15475415.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- spop 内部的具体特召执行行 Duel.SpecialSummon，以自身效果或条件的形式（SUMMON_VALUE_SELF）将卡片表侧攻击表示特殊召唤至对方玩家场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 效果 e2 的条件判断函数 ctcon，确认当前卡片是通过特殊召唤方式进入场上的（GetSummonType）。
function c15475415.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果 e2 的操作处理函数 ctop，在自身特殊召唤成功后，检索对方场上表侧表示且能接受 A 指示物效果的怪兽。
function c15475415.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- ctop 内部的具体获取卡组行 Duel.GetMatchingGroup，从对方场上的主要怪兽区域中筛选出能够添加 A 指示物的表侧表示的卡片，构建目标卡组 g。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,2 do
		-- ctop 内部的提示与选择逻辑，向玩家显示'请选择表侧表示的卡'的提示信息（HINT_SELECTMSG），并从筛选出的卡组中选择一张卡片进行后续处理（循环两次添加指示物）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
