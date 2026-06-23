--S－Force ミスティファイ
-- 效果：
-- 包含「治安战警队」怪兽的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡的正对面有对方怪兽存在，对方不能把这张卡作为效果的对象，不能用怪兽发动的效果把怪兽特殊召唤。
-- ②：自己·对方回合，以场上1只怪兽为对象才能发动。那只怪兽的位置向那个控制者的其他的主要怪兽区域移动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册需要2到3只怪兽作为连接召唤素材的连接召唤手续
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- ①：只要这张卡的正对面有对方怪兽存在，对方不能把这张卡作为效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	-- 设置不能被对方的效果作为对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 不能用怪兽发动的效果把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.indcon)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，以场上1只怪兽为对象才能发动。那只怪兽的位置向那个控制者的其他的主要怪兽区域移动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"移动"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.zonetg)
	e3:SetOperation(s.zoneop)
	c:RegisterEffect(e3)
end
-- 连接召唤的素材必须包含至少1只「治安战警队」怪兽的检查条件
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x156)
end
-- 过滤这张卡同纵列中对方场上存在的怪兽的条件
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp) and c:IsOnField()
end
-- 判断这张卡的正对面（同纵列）是否存在对方场上的怪兽的条件
function s.indcon(e)
	local cg=e:GetHandler():GetColumnGroup()
	return cg:IsExists(s.cfilter,1,nil,e:GetHandlerPlayer())
end
-- 限制特殊召唤的判定函数，如果特殊召唤是由怪兽发动的效果触发则予以限制
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se:IsActiveType(TYPE_MONSTER) and se:IsActivated()
		and c:IsType(TYPE_MONSTER)
end
-- 过滤场上其控制者的主要怪兽区域存在空余格子的怪兽的条件
function s.filter(c)
	-- 检查目标怪兽控制者的场上是否存在可用的主要怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,PLAYER_NONE,0)>0
end
-- 效果②（移动怪兽位置）的发动判定与效果目标设置函数
function s.zonetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 在发动判定的第一阶段，检查双方场上是否存在其控制者可以移动格子的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向当前玩家提示选择作为移动对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择移动位置的怪兽"
	-- 让玩家选择场上的1只怪兽作为移动对象，并将其注册为连锁对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②（移动怪兽位置）的效果处理主函数
function s.zoneop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果指向的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果目标怪兽与连锁不相关，或者其控制者的主要怪兽区域已没有可用空格，则结束处理
	if not tc:IsRelateToChain() or Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 向当前玩家提示选择要将怪兽移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	if tc:IsControler(tp) then
		-- 如果目标怪兽属于自己，则让玩家自己选择自己主要怪兽区域的一个可用空格作为移动目标
		local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		-- 向玩家发送被选中的格子区域的高亮提示
		Duel.Hint(HINT_ZONE,tp,fd)
		local seq=math.log(fd,2)
		-- 将属于自己的目标怪兽移动到选择的怪兽区域位置
		Duel.MoveSequence(tc,seq)
	else
		-- 如果目标怪兽属于对方，则让玩家自己选择对方主要怪兽区域的一个可用空格作为移动目标
		local fd=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
		-- 向玩家发送被选中的对方格子区域的高亮提示
		Duel.Hint(HINT_ZONE,tp,fd)
		local nseq=math.log(bit.rshift(fd,16),2)
		-- 将属于对方的目标怪兽移动到选择的怪兽区域位置
		Duel.MoveSequence(tc,nseq)
	end
end
